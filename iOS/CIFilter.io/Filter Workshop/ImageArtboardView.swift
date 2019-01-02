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

enum Colors {
    case primary
    case availabilityBlue
    case availabilityRed
    case borderGray

    var color: UIColor {
        switch self {
        case .primary: return UIColor(rgb: 0xF5BD5D)
        case .availabilityRed: return UIColor(rgb: 0xFF8D8D)
        case .availabilityBlue: return UIColor(rgb: 0x74AEDF)
        case .borderGray: return UIColor(rgb: 0xAFAFAF)
        }
    }
}

final class OutputImageActivityIndicatorView: UIView {
    private let activityView = UIActivityIndicatorView(style: .whiteLarge)
    init() {
        super.init(frame: .zero)
        self.backgroundColor = Colors.primary.color
        addSubview(activityView)
        activityView.disableTranslatesAutoresizingMaskIntoConstraints()
        activityView.centerXAnchor <=> self.centerXAnchor
        activityView.centerYAnchor <=> self.centerYAnchor
        self.widthAnchor <=> ImageChooserView.artboardSize
        self.heightAnchor <=> ImageChooserView.artboardSize
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        activityView.startAnimating()
    }

    func stopAnimating() {
        activityView.stopAnimating()
    }
}

final class ImageArtboardView: UIView {
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
    private let imageView = UIImageView()
    private let imageChooserView = ImageChooserView()
    private let activityView = OutputImageActivityIndicatorView()

    init(name: String) {
        super.init(frame: .zero)
        self.eitherView = EitherView(views: [imageView, imageChooserView, activityView])
        addSubview(eitherView)
        nameLabel.text = name
        self.addSubview(nameLabel)

        imageView.contentMode = .scaleToFill

        [nameLabel, imageView, eitherView].disableTranslatesAutoresizingMaskIntoConstraints()
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

        imageChooserView.didChooseImage.subscribe(onNext: { image in
            self.imageView.image = image
            self.eitherView.setEnabled(self.imageView)
        }).disposed(by: self.bag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(image: UIImage) {
        self.activityView.stopAnimating()
        imageView.image = image
        self.eitherView.setEnabled(self.imageView)
    }

    func setLoading() {
        self.eitherView.setEnabled(self.activityView)
        self.activityView.startAnimating()
    }
}
