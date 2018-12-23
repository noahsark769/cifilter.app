//
//  ImageChooserCell.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/23/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

final class ImageChooserCell: UICollectionViewCell {
    private let imageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.addSubview(imageView)
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 4
        imageView.contentMode = .scaleAspectFill
        imageView.disableTranslatesAutoresizingMaskIntoConstraints()
        imageView.edgesToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(image: UIImage) {
        imageView.image = image
    }
}
