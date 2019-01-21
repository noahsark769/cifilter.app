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
import CoreGraphics

final class ColorInputDragIndicatorView: UIView {
    private let shapeLayer = CAShapeLayer()
    private let colorLayer = CAShapeLayer()

    var sideLength: CGFloat = 0 {
        didSet {
            self.generatePaths()
        }
    }

    var indicatorColor: UIColor = .black {
        didSet {
            self.generatePaths()
        }
    }

    var cornerRadius: CGFloat = 0 {
        didSet {
            self.generatePaths()
        }
    }

    var color: CGColor? {
        get { return self.colorLayer.fillColor }
        set { self.colorLayer.fillColor = newValue }
    }

    init(sideLength: CGFloat, color: UIColor) {
        super.init(frame: .zero)
        self.layer.addSublayer(shapeLayer)
        self.layer.addSublayer(colorLayer)

        shapeLayer.fillColor = color.cgColor

        self.generatePaths()

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.36
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 10
    }

    private func generateShapePath() {
        let path = CGMutablePath()
        // upper left
        path.move(to: .zero)

        // upper right
        path.addLine(to: CGPoint(x: sideLength, y: 0))

        // lower right
        path.addLine(to: CGPoint(x: sideLength, y: sideLength))

        // bottom of point
        path.addLine(to: CGPoint(x: sideLength / 2, y: sideLength * 1.5))

        // lower left
        path.addLine(to: CGPoint(x: 0, y: sideLength))
        path.addLine(to: .zero)
        shapeLayer.path = path
    }

    private func generateColorPath() {
        let path = UIBezierPath(rect: CGRect(x: 4, y: 4, width: sideLength - 8, height: sideLength - 8)).cgPath
        colorLayer.path = path
    }

    private func generatePaths() {
        self.generateColorPath()
        self.generateShapePath()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ColorInput: UIView {
    private let imageView = UIImageView()
    private let draggableIndicatorView = ColorInputDragIndicatorView(sideLength: 40, color: UIColor(rgb: 0x333333))
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

        draggableIndicatorView.indicatorColor = UIColor(rgb: 0x333333)

        addSubview(draggableIndicatorView)
        draggableIndicatorView.disableTranslatesAutoresizingMaskIntoConstraints()
        let multiplier: CGFloat = 1 / 5
        draggableIndicatorView.widthAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: multiplier, constant: 0).isActive = true
        draggableIndicatorView.heightAnchor.constraint(equalTo: self.imageView.heightAnchor, multiplier: multiplier, constant: 0).isActive = true

        self.rx.panGesture(configuration: { gesture, recognizer in
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

        let multiplier: CGFloat = 1 / 5
        draggableIndicatorView.sideLength = self.imageView.frame.width * multiplier
        draggableIndicatorView.center = CGPoint(x: self.dragLocation.x, y: self.dragLocation.y - draggableIndicatorView.frame.height / 2 - draggableIndicatorView.sideLength / 2)
        draggableIndicatorView.color = self.imageView.getPixelColorAt(point: self.dragLocation).cgColor
    }
}
