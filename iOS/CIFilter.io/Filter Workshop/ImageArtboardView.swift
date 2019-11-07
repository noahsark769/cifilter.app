//
//  ImageArtboardView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/10/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import Combine
import SwiftUI

final class Target: NSObject {
    let didFire = PassthroughSubject<Void, Never>()

    @objc func fire() {
        didFire.send()
    }
}

final class CombineTapGestureRecognizer: UITapGestureRecognizer {
    fileprivate let target: Target

    init() {
        let target = Target()
        self.target = target
        super.init(target: target, action: #selector(Target.fire))
    }
}

final class CombinePanGestureRecognizer: UIPanGestureRecognizer {
    private var target: Target! = nil

    var strongDelegate: UIGestureRecognizerDelegate? = nil

    init() {
        let target = Target()
        super.init(target: target, action: #selector(Target.fire))
        self.target = target
    }

    func subscribe(_ receiveValue: @escaping (UIPanGestureRecognizer) -> Void) -> AnyCancellable {
        return self.target.didFire.sink(receiveValue: {
            receiveValue(self)
        })
    }
}

final class ControlPublisher<T: UIControl>: Publisher {
    typealias ControlEvent = (control: UIControl, event: UIControl.Event)
    typealias Output = ControlEvent
    typealias Failure = Never

    let subject = PassthroughSubject<Output, Failure>()

    convenience init(control: UIControl, event: UIControl.Event) {
        self.init(control: control, events: [event])
    }

    init(control: UIControl, events: [UIControl.Event]) {
        for event in events {
            control.addTarget(self, action: #selector(controlAction), for: event)
        }
    }

    @objc private func controlAction(sender: UIControl, forEvent event: UIControl.Event) {
        subject.send(ControlEvent(control: sender, event: event))
    }

    func receive<S>(subscriber: S) where S :
        Subscriber,
        ControlPublisher.Failure == S.Failure,
        ControlPublisher.Output == S.Input {

            subject.receive(subscriber: subscriber)
    }
}

extension UIView {
    func addTapHandler(numberOfTapsRequired: Int = 1) -> AnyPublisher<UITapGestureRecognizer, Never> {
        self.isUserInteractionEnabled = true
        let recognizer = CombineTapGestureRecognizer()
        recognizer.numberOfTapsRequired = numberOfTapsRequired
        self.addGestureRecognizer(recognizer)
        return recognizer.target.didFire.map { recognizer }.eraseToAnyPublisher()
    }

    func addPanHandler(
        configure: (UIPanGestureRecognizer) -> Void = { _ in },
        delegate: ((UIPanGestureRecognizer) -> UIGestureRecognizerDelegate)? = nil
    ) -> CombinePanGestureRecognizer {
        self.isUserInteractionEnabled = true
        let recognizer = CombinePanGestureRecognizer()
        if let delegate = delegate?(recognizer) {
            recognizer.strongDelegate = delegate
            recognizer.delegate = delegate
        }
        configure(recognizer)
        self.addGestureRecognizer(recognizer)
        return recognizer
    }
}

extension UIControl {
    func addControlEventsObserver(events: [UIControl.Event]) -> AnyPublisher<UIControl, Never> {
        return ControlPublisher(control: self, events: events).map { $0.control }.eraseToAnyPublisher()
    }
}

final class ImageArtboardView: UIView {
    enum Configuration {
        case input
        case output
    }

    private let configuration: Configuration
    private var eitherView: EitherView!
    private var cancellables = Set<AnyCancellable>()

    let didChooseImage = PassthroughSubject<UIImage, Never>()
    var didChooseAdd: PassthroughSubject<CGRect, Never> {
        return UserDefaultsConfig.swiftUIImageChooser ? swiftUIImageChooserView.didTapAdd : legacyImageChooserView.didChooseAdd
    }
    let didChooseSave = PassthroughSubject<Void, Never>()

    private let nameLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.monospacedHeaderFont()
        view.numberOfLines = 1
        return view
    }()
    private let noImageGeneratedView = OutputImageNotGeneratedView()
    private let imageView = UIImageView()
    private let legacyImageChooserView = ImageChooserView()

    private let swiftUIImageChooserView = ImageChooserSwiftUIView()
    private lazy var swiftUIImageChooserViewController = UIHostingController(rootView: swiftUIImageChooserView)

    private let activityView = OutputImageActivityIndicatorView()

    private lazy var dragInteraction: UIDragInteraction = {
        return UIDragInteraction(delegate: self)
    }()

    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()

    private let nameStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 0
        return view
    }()

    private let editButton: UIButton = {
        let view = UIButton()
        view.setTitleColor(Colors.availabilityBlue.color, for: .normal)
        view.setTitle("Edit", for: .normal)
        return view
    }()

    var imageChooserView: UIView {
        return UserDefaultsConfig.swiftUIImageChooser ? swiftUIImageChooserViewController.view! : legacyImageChooserView
    }

    init(name: String, configuration: Configuration) {
        self.configuration = configuration
        super.init(frame: .zero)

        self.eitherView = EitherView(views: [
            imageView, imageChooserView, activityView, noImageGeneratedView
        ])
        addSubview(mainStackView)
        mainStackView.edgesToSuperview()
        mainStackView.addArrangedSubview(nameStackView)
        nameLabel.text = name
        nameStackView.addArrangedSubview(nameLabel)

        imageView.contentMode = .scaleToFill

        [nameLabel, imageView, eitherView].disableTranslatesAutoresizingMaskIntoConstraints()

        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        nameLabel.setContentHuggingPriority(.required, for: .vertical)
        self.eitherView.setEnabled(imageChooserView)
        mainStackView.addArrangedSubview(eitherView)

        legacyImageChooserView.didChooseImage.sink(receiveValue: { image in
            self.set(image: image)
        }).store(in: &self.cancellables)
        swiftUIImageChooserView.didTapImage.sink(receiveValue: { image in
            self.set(image: image.image)
        }).store(in: &self.cancellables)

        imageView.layer.borderColor = UIColor(rgb: 0xdddddd).cgColor
        imageView.layer.borderWidth = 1

        nameStackView.addArrangedSubview(editButton)

        editButton.addTapHandler().sink { _ in
            self.setChoosing()
        }.store(in: &self.cancellables)

        editButton.isHidden = true
        editButton.setContentHuggingPriority(.required, for: .horizontal)


        if #available(iOS 13, *) {
            imageView.addInteraction(UIContextMenuInteraction(delegate: self))
        }

        legacyImageChooserView.didChooseImage.subscribe(self.didChooseImage).store(in: &self.cancellables)
        swiftUIImageChooserView.didTapImage.map(\.image).subscribe(self.didChooseImage).store(in: &self.cancellables)

        if UserDefaultsConfig.swiftUIImageChooser {
            swiftUIImageChooserViewController.view!.heightAnchor.constraint(equalToConstant: 650).isActive = true
            swiftUIImageChooserViewController.view!.widthAnchor.constraint(equalToConstant: 650).isActive = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: These functions should be condensed into one that takes an enum
    func set(image: UIImage, reportOnSubject: Bool = false) {
        self.activityView.stopAnimating()
        imageView.image = image
        imageView.isUserInteractionEnabled = true
        self.eitherView.setEnabled(self.imageView)
        self.editButton.isHidden = self.configuration != .input

        if reportOnSubject {
            didChooseImage.send(image)
        }
        self.addInteraction(self.dragInteraction)
    }

    func setChoosing() {
        self.removeInteraction(self.dragInteraction)
        self.activityView.stopAnimating()
        self.eitherView.setEnabled(self.imageChooserView)
        self.editButton.isHidden = true
    }

    func setLoading() {
        self.removeInteraction(self.dragInteraction)
        self.eitherView.setEnabled(self.activityView)
        self.activityView.startAnimating()
        self.editButton.isHidden = true
    }

    func setDefault() {
        self.removeInteraction(self.dragInteraction)
        self.activityView.stopAnimating()
        self.eitherView.setEnabled(self.noImageGeneratedView)
        self.editButton.isHidden = true
    }
}

@available(iOS 13, *)
extension ImageArtboardView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in

            var actions: [UIAction] = []

            if self.configuration == .input {
                actions.append(UIAction(title: "Choose another image", image: UIImage(systemName: "square.and.pencil")) { action in
                    self.setChoosing()
                })
            } else {
                actions.append(UIAction(title: "Save image", image: UIImage(systemName: "square.and.arrow.up")) { action in
                    self.didChooseSave.send()
                })
            }

            // Create our menu with both the edit menu and the share action
            return UIMenu(title: "Image options", children: actions)
        })
    }
}

extension ImageArtboardView: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = imageView.image else {
            return []
        }
        return [
            UIDragItem(itemProvider: NSItemProvider(object: image))
        ]
    }
}
