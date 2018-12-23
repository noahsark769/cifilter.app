//
//  ImageArtboardView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/10/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

import UIKit

final class EitherView: UIView {
    private let firstView: UIView
    private let secondView: UIView
    init(_ firstView: UIView, _ secondView: UIView) {
        self.firstView = firstView
        self.secondView = secondView
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setEnabled(_ view: UIView) {
        if view == self.firstView {
            addSubview(self.firstView)
            self.firstView.edgesToSuperview()
            self.secondView.removeFromSuperview()
            self.firstView.edgesToSuperview()
        } else if view == self.secondView {
            addSubview(self.secondView)
            self.secondView.edgesToSuperview()
            self.firstView.removeFromSuperview()
            self.secondView.edgesToSuperview()
        } else {
            print("WARNING tried to set a view enabled that was not part of EitherView")
        }
    }
}

final class ImageArtboardView: UIView {
    private var eitherView: EitherView!

    private let nameLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = UIFont(name: "Courier New", size: 17)
        view.numberOfLines = 1
        return view
    }()
    private let imageView = UIImageView()
    private let containerView = UIView()
    private let imageChooserView = ImageChooserView()

    init(name: String) {
        super.init(frame: .zero)
        self.eitherView = EitherView(containerView, imageChooserView)
        addSubview(eitherView)
        nameLabel.text = name
        containerView.addSubview(nameLabel)
        containerView.addSubview(imageView)

        imageView.contentMode = .scaleToFill

        [nameLabel, imageView].disableTranslatesAutoresizingMaskIntoConstraints()
        containerView.topAnchor <=> nameLabel.topAnchor
        nameLabel.bottomAnchor <=> imageView.topAnchor -- 10
        imageView.bottomAnchor <=> containerView.bottomAnchor
        nameLabel.leadingAnchor <=> containerView.leadingAnchor
        imageView.leadingAnchor <=> containerView.leadingAnchor
        nameLabel.trailingAnchor <=> containerView.trailingAnchor
        imageView.trailingAnchor <=> containerView.trailingAnchor

        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        self.containerView.edgesToSuperview()
        self.eitherView.setEnabled(self.imageChooserView)
        eitherView.edgesToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(image: UIImage) {
        imageView.image = image
    }
}
