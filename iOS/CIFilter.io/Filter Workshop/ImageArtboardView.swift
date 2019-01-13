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
    private var eitherView: EitherView!
    private let bag = DisposeBag()
    var didChooseImage: ControlEvent<UIImage> {
        return imageChooserView.didChooseImage
    }

    let didSaveImage = PublishSubject<UIImage>()

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

    private let saveButton: UIButton = {
        let view = UIButton()
        view.setTitle("Save", for: [.normal])
        view.setTitleColor(Colors.availabilityBlue.color, for: [.normal])
        view.setContentHuggingPriority(.required, for: .vertical)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 26)
        return view
    }()

    var enableSavingToPhotos: Bool = false

    init(name: String) {
        super.init(frame: .zero)
        self.eitherView = EitherView(views: [
            imageView, imageChooserView, activityView, noImageGeneratedView
        ])
        addSubview(eitherView)
        nameLabel.text = name
        self.addSubview(nameLabel)

        imageView.contentMode = .scaleToFill

        [nameLabel, imageView, eitherView, saveButton].disableTranslatesAutoresizingMaskIntoConstraints()
        self.topAnchor <=> nameLabel.topAnchor
        nameLabel.bottomAnchor <=> eitherView.topAnchor -- 10
        eitherView.bottomAnchor <=> self.bottomAnchor

        nameLabel.leadingAnchor <=> self.leadingAnchor
        nameLabel.trailingAnchor <=> self.trailingAnchor
        eitherView.leadingAnchor <=> self.leadingAnchor
        eitherView.trailingAnchor <=> self.trailingAnchor

        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        nameLabel.setContentHuggingPriority(.required, for: .vertical)
        self.eitherView.setEnabled(self.imageChooserView)

        addSubview(saveButton)
        eitherView.bottomAnchor <=> saveButton.topAnchor -- 200
        eitherView.trailingAnchor <=> saveButton.trailingAnchor
        saveButton.isHidden = true
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)

        imageChooserView.didChooseImage.subscribe(onNext: { image in
            self.imageView.image = image
            self.eitherView.setEnabled(self.imageView)
        }).disposed(by: self.bag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: These functions should be condensed into one that takes an enum
    func set(image: UIImage) {
        self.activityView.stopAnimating()
        imageView.image = image
        self.eitherView.setEnabled(self.imageView)

        if self.enableSavingToPhotos {
            saveButton.isHidden = false
        }
    }

    func setLoading() {
        saveButton.isHidden = true
        self.eitherView.setEnabled(self.activityView)
        self.activityView.startAnimating()
    }

    func setDefault() {
        saveButton.isHidden = true
        self.activityView.stopAnimating()
        self.eitherView.setEnabled(self.noImageGeneratedView)
    }

    @objc private func didTapSave() {
        guard let image = self.imageView.image else { return }
        self.didSaveImage.onNext(image)
    }
}
