//
//  ColorInput.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/16/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class ColorInput: UIView {
    private let imageView = UIImageView()
    private let draggableIndicatorView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(rgb: 0xcccccc).cgColor
        view.layer.borderWidth = 4
        view.layer.cornerRadius = 4
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.36
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowRadius = 10
        return view
    }()
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    private var dragLocation: CGPoint = .zero
    private var lastLocation: CGPoint = .zero
    private let bag = DisposeBag()

    init(defaultValue: CIColor) {
        // TODO: defaultValue is currently unused
        super.init(frame: .zero)
        let filter = CIFilter(name: "CIHueSaturationValueGradient", parameters: [
            "inputColorSpace": self.colorSpace,
            "inputDither": NSNumber(floatLiteral: 0),
            "inputRadius": NSNumber(integerLiteral: 100),
            "inputSoftness": NSNumber(integerLiteral: 0),
            "inputValue": NSNumber(integerLiteral: 1)
        ])!
        let image = UIImage(ciImage: filter.outputImage!)
        imageView.contentMode = .scaleAspectFill
        imageView.image = image

        addSubview(imageView)
        imageView.edgesToSuperview()

        addSubview(draggableIndicatorView)
        draggableIndicatorView.disableTranslatesAutoresizingMaskIntoConstraints()
        let multiplier: CGFloat = 1 / 5
        draggableIndicatorView.widthAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: multiplier, constant: 0).isActive = true
        draggableIndicatorView.heightAnchor.constraint(equalTo: self.imageView.heightAnchor, multiplier: multiplier, constant: 0).isActive = true

        draggableIndicatorView.rx.panGesture(configuration: { gesture, recognizer in
            recognizer.simultaneousRecognitionPolicy = .never
            FilterWorkshopView.globalPanGestureRecognizer.require(toFail: gesture)
        }).subscribe(onNext: { recognizer in
            if case .began = recognizer.state {
                self.dragLocation = recognizer.location(in: self)
                self.setNeedsLayout()
            } else if case .changed = recognizer.state {
                self.dragLocation = recognizer.location(in: self)
                self.setNeedsLayout()
            }
        }).disposed(by: bag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        draggableIndicatorView.center = self.dragLocation
        draggableIndicatorView.backgroundColor = self.imageView.getPixelColorAt(point: self.dragLocation)
    }
}
