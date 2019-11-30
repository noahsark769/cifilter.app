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

/// A `UIView` subclass capable of hosting a SwiftUI view.
open class UIHostingView<Content: View>: UIView {
    private let rootViewHostingController: UIHostingController<Content>

    public var rootView: Content {
        get {
            return rootViewHostingController.rootView
        } set {
            rootViewHostingController.rootView = newValue
        }
    }

    public required init(rootView: Content) {
        self.rootViewHostingController = UIHostingController(rootView: rootView)

        super.init(frame: .zero)

        rootViewHostingController.view.backgroundColor = .clear

        addSubview(rootViewHostingController.view)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        rootViewHostingController.view.frame = self.bounds
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        rootViewHostingController.sizeThatFits(in: size)
    }

    override open func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        rootViewHostingController.sizeThatFits(in: targetSize)
    }
}

final class ImageArtboardView: UIView {
    static let artboardSize: CGFloat = 650

    enum Configuration {
        case input
        case output
    }

    private let configuration: Configuration
    private var eitherView: EitherView!
    private var cancellables = Set<AnyCancellable>()

    let didChooseImage = PassthroughSubject<UIImage, Never>()
    var didChooseAdd: PassthroughSubject<CGRect, Never> {
        return swiftUIImageChooserView.didTapAdd
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

    private lazy var dropInteraction: UIDropInteraction = {
        return UIDropInteraction(delegate: self)
    }()

    var imageChooserView: UIView {
        return swiftUIImageChooserViewController.view!
    }

    private let dropIndicatorView = UIHostingView(rootView: ImageArtboardDropIndicatorView())

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

        swiftUIImageChooserView.didTapImage.map(\.image).subscribe(self.didChooseImage).store(in: &self.cancellables)

        swiftUIImageChooserViewController.view!.heightAnchor.constraint(equalToConstant: 650).isActive = true
        swiftUIImageChooserViewController.view!.widthAnchor.constraint(equalToConstant: 650).isActive = true

        if self.configuration == .input {
            self.addInteraction(self.dropInteraction)
        }

        self.addSubview(self.dropIndicatorView)
        self.dropIndicatorView.isHidden = true
        self.dropIndicatorView.edges(to: self)
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

extension ImageArtboardView: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        // Ensure the drop session has an object of the appropriate type
        let result = session.canLoadObjects(ofClass: UIImage.self)
        return result
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        // Propose to the system to copy the item from the source app
        return UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        self.dropIndicatorView.isHidden = false
    }

    func dropInteraction(_ interaction: UIDropInteraction, concludeDrop session: UIDropSession) {
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        self.dropIndicatorView.isHidden = true
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        // Consume drag items (in this example, of type UIImage).
        session.loadObjects(ofClass: UIImage.self) { imageItems in

            let images = imageItems as! [UIImage]
            self.set(image: images.first!, reportOnSubject: true)
        }
        self.dropIndicatorView.isHidden = true
    }
}
