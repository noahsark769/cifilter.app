//
//  ImageChooserView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/23/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import ColorCompatibility
import Combine

final class ImageChooserAddView: UIView {
    let didTap = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private var plusLabel: UILabel = {
        let view = UILabel()
        view.text = "Add"
        view.accessibilityLabel = "Add Image"
        view.font = UIFont.systemFont(ofSize: 30)
        view.textColor = ColorCompatibility.label
        view.setContentHuggingPriority(.required, for: .vertical)
        return view
    }()

    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor <=> ImageChooserView.imageSize
        self.heightAnchor <=> ImageChooserView.imageSize
        self.backgroundColor = Colors.availabilityBlue.color

        addSubview(plusLabel)
        plusLabel.translatesAutoresizingMaskIntoConstraints = false
        plusLabel.centerXAnchor <=> self.centerXAnchor
        plusLabel.centerYAnchor <=> self.centerYAnchor
        self.addTapHandler()
            .map { _ in }
            .subscribe(self.didTap)
            .store(in: &self.cancellables)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private let artboardPadding: CGFloat = 20
private let artboardSpacing: CGFloat = 20
private let numImagePerArtboardRow = 3

final class ImageChooserView: UIView {
    static let artboardSize: CGFloat = 650

    private var cancellables = Set<AnyCancellable>()

    let didChooseImage = PassthroughSubject<UIImage, Never>()
    let didChooseAdd = PassthroughSubject<CGRect, Never>()

    static var imageSize: CGFloat {
        return (ImageChooserView.artboardSize - (artboardPadding * 2) - (artboardSpacing * 2)) / CGFloat(numImagePerArtboardRow)
    }

    private let verticalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = artboardSpacing
        view.alignment = .leading
        return view
    }()

    private func newStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = artboardSpacing
        return view
    }

    private let addView = ImageChooserAddView()
    private lazy var dropInteraction: UIDropInteraction = {
        return UIDropInteraction(delegate: self)
    }()

    init() {
        super.init(frame: .zero)
        self.backgroundColor = ColorCompatibility.systemGray6

        addSubview(verticalStackView)
        verticalStackView.edgesToSuperview(insets: UIEdgeInsets(all: artboardPadding))

        var currentStackView: UIStackView! = nil
        for (i, builtInImage) in BuiltInImage.all.enumerated() {
            if i % numImagePerArtboardRow == 0 {
                currentStackView = newStackView()
                verticalStackView.addArrangedSubview(currentStackView)
            }
            currentStackView.addArrangedSubview(self.newImageView(image: builtInImage))
        }

        if BuiltInImage.all.count % numImagePerArtboardRow == 0 {
            currentStackView = newStackView()
            verticalStackView.addArrangedSubview(currentStackView)
        }
        currentStackView.addArrangedSubview(addView)

        addView.didTap.sink {
            self.didChooseAdd.send(self.window!.convert(self.addView.bounds, from: self.addView))
        }.store(in: &self.cancellables)

        self.addInteraction(self.dropInteraction)
    }

    private func newImageView(image: BuiltInImage) -> UIImageView {
        let imageView = UIImageView(image: image.imageForImageChooser)
        imageView.heightAnchor <=> ImageChooserView.imageSize
        imageView.widthAnchor <=> ImageChooserView.imageSize
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.layer.borderColor = ColorCompatibility.systemGray4.cgColor
        imageView.layer.borderWidth = 1
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.addTapHandler().sink { _ in
            self.didChooseImage.send(image.image)
        }.store(in: &self.cancellables)
        return imageView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageChooserView: UIDropInteractionDelegate {
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
    }

    func dropInteraction(_ interaction: UIDropInteraction, concludeDrop session: UIDropSession) {
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        // Consume drag items (in this example, of type UIImage).
        session.loadObjects(ofClass: UIImage.self) { imageItems in

            let images = imageItems as! [UIImage]
            self.didChooseImage.send(images.first!)
        }
    }
}
