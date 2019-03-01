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

        let upperLeft = CGPoint.zero
        let upperRight = CGPoint(x: sideLength, y: 0)
        let lowerRight = CGPoint(x: sideLength, y: sideLength)
        let lowerLeft = CGPoint(x: 0, y: sideLength)
        let bottomTip = CGPoint(x: sideLength / 2, y: sideLength * 1.5)

        // upper left
        path.move(to: upperLeft.offsetX(by: cornerRadius))

        // upper right
        path.addLine(to: upperRight.offsetX(by: -cornerRadius))
        path.addArc(tangent1End: upperRight, tangent2End: upperRight.offsetY(by: cornerRadius), radius: cornerRadius)

        // lower right
        path.addLine(to: lowerRight.offsetY(by: -cornerRadius))
        path.addArc(tangent1End: lowerRight, tangent2End: lowerRight.offsetY(by: cornerRadius).offsetX(by: -cornerRadius), radius: cornerRadius)

        // bottom of point
        path.addLine(to: bottomTip)

        // lower left
        path.addLine(to: lowerLeft.offsetX(by: cornerRadius).offsetY(by: cornerRadius))
        path.addArc(tangent1End: lowerLeft, tangent2End: lowerLeft.offsetY(by: -cornerRadius), radius: cornerRadius)

        // upper left
        path.addLine(to: upperLeft.offsetY(by: cornerRadius))
        path.addArc(tangent1End: upperLeft, tangent2End: upperLeft.offsetX(by: cornerRadius), radius: cornerRadius)
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

    override var intrinsicContentSize: CGSize {
        return CGSize(width: sideLength, height: sideLength * 1.5)
    }
}

final class ColorInput: UIView {
    private static let nullDragLocation = CGPoint(x: -1, y: -1)
    private let mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 5
        return view
    }()
    private let hexInput: ColorHexInput
    private let imageView = UIImageView()
    private let draggableIndicatorView = ColorInputDragIndicatorView(sideLength: 40, color: UIColor(rgb: 0x333333))
    private var dragLocation: CGPoint = ColorInput.nullDragLocation
    private var lastLocation: CGPoint = .zero
    private let bag = DisposeBag()
    let valueDidChange = PublishSubject<CIColor>()

    init(defaultValue: CIColor) {
        // TODO: defaultValue is currently unused
        self.hexInput = ColorHexInput(default: UIColor(ciColor: defaultValue))
        super.init(frame: .zero)
        let filter = CIFilter(name: "CIHueSaturationValueGradient", parameters: [
            "inputColorSpace": CGColorSpaceCreateDeviceRGB(),
            "inputDither": NSNumber(floatLiteral: 0),
            "inputRadius": NSNumber(integerLiteral: 200),
            "inputSoftness": NSNumber(integerLiteral: 0),
            "inputValue": NSNumber(integerLiteral: 1)
        ])!
        let image = UIImage(ciImage: filter.outputImage!)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image

        addSubview(mainStackView)
        mainStackView.edgesToSuperview()
        mainStackView.addArrangedSubview(imageView)
        mainStackView.addArrangedSubview(hexInput)

        draggableIndicatorView.indicatorColor = UIColor(rgb: 0x333333)
        draggableIndicatorView.cornerRadius = 4

        addSubview(draggableIndicatorView)

        self.imageView.rx.panGesture(configuration: { gesture, recognizer in
            recognizer.simultaneousRecognitionPolicy = .never
            FilterWorkshopView.globalPanGestureRecognizer.require(toFail: gesture)
        }).subscribe(onNext: { recognizer in
            if case .began = recognizer.state {
                self.dragLocation = recognizer.location(in: self.imageView)
                self.setNeedsLayout()
                self.reportColorFromDragLocation()
            } else if case .changed = recognizer.state {
                self.dragLocation = recognizer.location(in: self.imageView)
                self.setNeedsLayout()
                self.reportColorFromDragLocation()
            }
        }).disposed(by: bag)

        self.imageView.rx.tapGesture().subscribe(onNext: { recognizer in
            let supportedStates: [UIGestureRecognizer.State] = [.began, .changed, .ended]
            guard supportedStates.contains(recognizer.state) else { return }
            self.dragLocation = recognizer.location(in: self)
            self.setNeedsLayout()
            self.reportColorFromDragLocation()
        }).disposed(by: bag)

        self.hexInput.valueDidChange.subscribe(onNext: { color in
            let colorLocation = self.imageView.pointOnColorWheel(for: color)
            self.dragLocation = colorLocation
            self.setNeedsLayout()
            self.report(color: color)
        }).disposed(by: bag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func report(color: UIColor) {
        let ciColor = CIColor(color: color)
        self.valueDidChange.onNext(ciColor)
    }

    private func reportColorFromDragLocation() {
        let color = self.imageView.getPixelColorAt(point: self.dragLocation)
        self.hexInput.set(text: color.toHexString())
        self.report(color: color)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.dragLocation == ColorInput.nullDragLocation {
            self.dragLocation = imageView.center
        }

        // don't do anything if we're outside the color wheel's radius
        guard self.dragLocation.isInside(circleWithRadius: imageView.bounds.width / 2, centeredAt: imageView.center) else {
            return
        }

        let multiplier: CGFloat = 1 / 5
        draggableIndicatorView.sideLength = self.imageView.frame.width * multiplier
        draggableIndicatorView.frame = CGRect(
            origin: CGPoint(
                x: self.dragLocation.x - draggableIndicatorView.sideLength / 2,
                y: self.dragLocation.y - draggableIndicatorView.intrinsicContentSize.height
            ),
            size: draggableIndicatorView.intrinsicContentSize
        )
        draggableIndicatorView.color = self.imageView.getPixelColorAt(point: self.dragLocation).cgColor
    }
}
