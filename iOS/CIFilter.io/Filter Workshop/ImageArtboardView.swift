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
    var didChooseImage: ControlEvent<UIImage> {
        return imageChooserView.didChooseImage
    }

    private let nameLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "Courier New", size: 17)
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
        imageChooserView.didChooseAdd.subscribe(onNext: { _ in
            print("CHOOSE ADD")
        }).disposed(by: self.bag)


        imageView.layer.borderColor = UIColor(rgb: 0xdddddd).cgColor
        imageView.layer.borderWidth = 1

        nameStackView.addArrangedSubview(editButton)
        editButton.rx.tap.subscribe(onNext: {
            self.setChoosing()
        }).disposed(by: bag)
        editButton.isHidden = true
        editButton.setContentHuggingPriority(.required, for: .horizontal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: These functions should be condensed into one that takes an enum
    func set(image: UIImage) {
        self.activityView.stopAnimating()
        imageView.image = image
        self.eitherView.setEnabled(self.imageView)
        self.editButton.isHidden = self.configuration != .input
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
