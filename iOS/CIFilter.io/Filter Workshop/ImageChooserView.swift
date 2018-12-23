//
//  ImageChooserView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/23/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

private let artboardSize: CGFloat = 650
private let artboardPadding: CGFloat = 20
private let artboardSpacing: CGFloat = 20
private let numImagePerArtboardRow = 3

private let builtInImageNames = [
    "knighted",
    "liberty"
]

final class ImageChooserView: UIView {
    private let bag = DisposeBag()
    private let chooseImageSubject = PublishSubject<UIImage>()
    lazy var didChooseImage = {
        return ControlEvent<UIImage>(events: chooseImageSubject)
    }()

    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(rgb: 0xeeeeee)
        self.disableTranslatesAutoresizingMaskIntoConstraints()
        self.widthAnchor <=> artboardSize
        self.heightAnchor <=> artboardSize

        // TODO: refactor this hacky code
        let imageSize = (artboardSize - (artboardPadding * 2) - (artboardSpacing * 2)) / 3
        for (i, imageName) in builtInImageNames.enumerated() {
            let image = UIImage(named: imageName)!
            let imageView = UIImageView(image: image)
            let row = i % numImagePerArtboardRow
            let column = Int(i / 3)
            imageView.frame = CGRect(
                x: artboardPadding + (imageSize + artboardSpacing) * CGFloat(column),
                y: artboardPadding + (imageSize + artboardSpacing) * CGFloat(row),
                width: imageSize,
                height: imageSize
            )
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 4
            imageView.rx.tapGesture().when(.ended).subscribe({ tap in
                self.chooseImageSubject.onNext(image)
            }).disposed(by: self.bag)
            addSubview(imageView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
