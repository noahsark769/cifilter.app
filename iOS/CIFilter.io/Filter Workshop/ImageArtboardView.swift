//
//  ImageArtboardView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/10/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ImageArtboardView: UIView {
    enum Configuration {
        case input
        case output
    }

    private let configuration: Configuration
    private var eitherView: EitherView!
    private let bag = DisposeBag()
    var didChooseImage = PublishSubject<UIImage>()
    var didChooseAdd: PublishSubject<UIView> {
        return imageChooserView.didChooseAdd
    }
    let didChooseSave = PublishSubject<Void>()

    private let nameLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.monospacedHeaderFont()
        view.numberOfLines = 1
        return view
    }()
    private let noImageGeneratedView = OutputImageNotGeneratedView()
    private let imageView = UIImageView()
    private let imageChooserView = ImageChooserView()
    private let activityView = OutputImageActivityIndicatorView()

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
        self.eitherView.setEnabled(self.imageChooserView)
        mainStackView.addArrangedSubview(eitherView)

        imageChooserView.didChooseImage.subscribe(onNext: { image in
            self.set(image: image)
        }).disposed(by: self.bag)

        imageView.layer.borderColor = UIColor(rgb: 0xdddddd).cgColor
        imageView.layer.borderWidth = 1

        nameStackView.addArrangedSubview(editButton)
        editButton.rx.tap.subscribe(onNext: {
            self.setChoosing()
        }).disposed(by: bag)
        editButton.isHidden = true
        editButton.setContentHuggingPriority(.required, for: .horizontal)

        imageChooserView.didChooseImage.bind(to: self.didChooseImage).disposed(by: bag)

        if #available(iOS 13, *) {
            imageView.addInteraction(UIContextMenuInteraction(delegate: self))
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
            didChooseImage.onNext(image)
        }
    }

    func setChoosing() {
        self.activityView.stopAnimating()
        self.eitherView.setEnabled(self.imageChooserView)
        self.editButton.isHidden = true
    }

    func setLoading() {
        self.eitherView.setEnabled(self.activityView)
        self.activityView.startAnimating()
        self.editButton.isHidden = true
    }

    func setDefault() {
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
                    self.didChooseSave.onNext(())
                })
            }

            // Create our menu with both the edit menu and the share action
            return UIMenu(title: "Image options", children: actions)
        })
    }
}
