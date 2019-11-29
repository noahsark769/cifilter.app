//
//  ColorInput.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/16/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit
import Combine
import CoreGraphics

final class GestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    typealias TwoRecognizersBooleanCallback = (UIGestureRecognizer, UIGestureRecognizer) -> Bool

    let recognizeSimulaneously: TwoRecognizersBooleanCallback

    init(recognizeSimulaneously: @escaping TwoRecognizersBooleanCallback) {
        self.recognizeSimulaneously = recognizeSimulaneously
        super.init()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.recognizeSimulaneously(gestureRecognizer, otherGestureRecognizer)
    }

    static let neverRecognizeSimultaneously = GestureRecognizerDelegate(recognizeSimulaneously: { _, _ in return false })
}

final class ColorInput: UIControl, ControlValueReporting {
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
    private var cancellables = Set<AnyCancellable>()
    private(set) var value = CIColor.black
    private var hexInputValueChanged: AnyPublisher<ColorHexInput.ValueType, Never>!

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

        draggableIndicatorView.indicatorColor = ColorCompatibility.secondaryLabel
        draggableIndicatorView.cornerRadius = 4

        addSubview(draggableIndicatorView)

        self.imageView.addPanHandler(configure: { recognizer in
            FilterWorkshopView.globalPanGestureRecognizer.require(toFail: recognizer)
        }, delegate: { _ in
            return GestureRecognizerDelegate.neverRecognizeSimultaneously
        }).subscribe { recognizer in
            if case .began = recognizer.state {
                self.dragLocation = recognizer.location(in: self.imageView)
                self.setNeedsLayout()
                self.reportColorFromDragLocation()
            } else if case .changed = recognizer.state {
                self.dragLocation = recognizer.location(in: self.imageView)
                self.setNeedsLayout()
                self.reportColorFromDragLocation()
            }
        }.store(in: &self.cancellables)

        self.imageView.addTapHandler().sink { recognizer in
            let supportedStates: [UIGestureRecognizer.State] = [.began, .changed, .ended]
            guard supportedStates.contains(recognizer.state) else { return }
            self.dragLocation = recognizer.location(in: self)
            self.setNeedsLayout()
            self.reportColorFromDragLocation()
        }.store(in: &self.cancellables)

        hexInputValueChanged = self.hexInput.addValueChangedObserver()
        hexInputValueChanged.sink { color in
            let colorLocation = self.imageView.pointOnColorWheel(for: color)
            self.dragLocation = colorLocation
            self.setNeedsLayout()
            self.report(color: color)
        }.store(in: &self.cancellables)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func report(color: UIColor) {
        let ciColor = CIColor(color: color)
        self.value = ciColor
        self.sendActions(for: .valueChanged)
    }

    private func reportColorFromDragLocation() {
        let color = self.imageView.getPixelColorAt(point: self.dragLocation)
        self.hexInput.set(text: color.toHexString())
        self.report(color: color)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        draggableIndicatorView.indicatorColor = ColorCompatibility.secondaryLabel

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
