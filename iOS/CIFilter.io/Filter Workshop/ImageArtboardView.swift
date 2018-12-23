//
//  ImageArtboardView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/10/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

final class ImageArtboardView: UIView {
    private let nameLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = UIFont(name: "Courier New", size: 17)
        view.numberOfLines = 1
        return view
    }()

    private let imageView = UIImageView()

    init(name: String) {
        super.init(frame: .zero)
        nameLabel.text = name
        addSubview(nameLabel)
        addSubview(imageView)

        imageView.contentMode = .scaleToFill

        [nameLabel, imageView].disableTranslatesAutoresizingMaskIntoConstraints()
        self.topAnchor <=> nameLabel.topAnchor
        nameLabel.bottomAnchor <=> imageView.topAnchor -- 10
        imageView.bottomAnchor <=> self.bottomAnchor
        nameLabel.leadingAnchor <=> self.leadingAnchor
        imageView.leadingAnchor <=> self.leadingAnchor
        nameLabel.trailingAnchor <=> self.trailingAnchor
        imageView.trailingAnchor <=> self.trailingAnchor

        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(image: UIImage) {
        imageView.image = image
    }
}
