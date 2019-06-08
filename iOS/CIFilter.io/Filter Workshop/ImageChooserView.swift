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

import UIKit

final class ImageChooserAddView: UIView {
    let didTap = PublishSubject<Void>()
    private let bag = DisposeBag()
    
    private var plusLabel: UILabel = {
        let view = UILabel()
        view.text = "Add"
        view.accessibilityLabel = "Add Image"
        view.font = UIFont.systemFont(ofSize: 30)
        view.textColor = .label
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
        self.rx.tapGesture().when(.ended).subscribe({ _ in
            self.didTap.onNext(())
        }).disposed(by: bag)
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
    private let bag = DisposeBag()
    private let chooseImageSubject = PublishSubject<UIImage>()
    lazy var didChooseImage = {
        return ControlEvent<UIImage>(events: chooseImageSubject)
    }()
    var didChooseAdd = PublishSubject<UIView>()

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

    init() {
        super.init(frame: .zero)
        self.backgroundColor = .quaternarySystemFill

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

        addView.didTap.subscribe(onNext: {
            self.didChooseAdd.onNext(self.addView)
        }).disposed(by: bag)
    }

    private func newImageView(image: BuiltInImage) -> UIImageView {
        let imageView = UIImageView(image: image.imageForImageChooser)
        imageView.heightAnchor <=> ImageChooserView.imageSize
        imageView.widthAnchor <=> ImageChooserView.imageSize
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
