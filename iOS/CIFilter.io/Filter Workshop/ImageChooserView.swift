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

private let artboardPadding: CGFloat = 20
private let artboardSpacing: CGFloat = 20
private let numImagePerArtboardRow = 3

final class ImageChooserView: UIView {
    static let artboardSize: CGFloat = 650
    private let bag = DisposeBag()
    private let chooseImageSubject = PublishSubject<UIImage>()
    lazy var didChooseImage = {
        return ControlEvent<UIImage>(events: chooseImageSubject)
    }()

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

    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(rgb: 0xf3f3f3)

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
    }

    private func newImageView(image: BuiltInImage) -> UIImageView {
        let imageSize = (ImageChooserView.artboardSize - (artboardPadding * 2) - (artboardSpacing * 2)) / 3
        let imageView = UIImageView(image: image.imageForImageChooser)
        imageView.heightAnchor <=> imageSize
        imageView.widthAnchor <=> imageSize
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.layer.borderColor = UIColor(rgb: 0xdddddd).cgColor
        imageView.layer.borderWidth = 1
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.rx.tapGesture().when(.ended).subscribe({ tap in
            self.chooseImageSubject.onNext(image.image)
        }).disposed(by: self.bag)
        return imageView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
