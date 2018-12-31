//
//  NumericSlider.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/24/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 * TODO: This slider is not used anywhere, but we're keeping it here in case there becomes a use case
 * for it. We can re-evaluate whether we need it when the app is released.
 */
final class NumericSlider: UIView {
    private let valueDidChangeObservable = PublishSubject<Float>()
    lazy var valueDidChange: ControlEvent<Float> = {
        return ControlEvent(events: valueDidChangeObservable)
    }()

    private let slider = UISlider()
    private let minimumLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "Courier New", size: 17)
        return view
    }()
    private let maximumLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "Courier New", size: 17)
        return view
    }()
    private let valueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "Courier New", size: 17)
        return view
    }()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        return view
    }()

    init(min: Float, max: Float, defaultValue: Float? = nil) {
        super.init(frame: .zero)
        addSubview(stackView)
        stackView.addArrangedSubview(minimumLabel)
        stackView.addArrangedSubview(slider)
        stackView.addArrangedSubview(maximumLabel)

        addSubview(valueLabel)

        minimumLabel.text = "\(min)"
        maximumLabel.text = "\(max)"
        stackView.edgesToSuperview()

        slider.minimumValue = min
        slider.maximumValue = max

        let initialValue: Float = defaultValue ?? min
        slider.value = initialValue
        valueLabel.text = "\(initialValue)"

        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }

    @objc private func sliderValueChanged() {
        let thumbRect = slider.thumbRect(forBounds: slider.frame, trackRect: slider.trackRect(forBounds: slider.frame), value: slider.value)
        valueLabel.text = String(format: "%.2f", slider.value)
        valueLabel.frame = CGRect(
            x: thumbRect.minX - (valueLabel.intrinsicContentSize.width - thumbRect.width) / 2,
            y: thumbRect.maxY + 10,
            width: valueLabel.intrinsicContentSize.width,
            height: valueLabel.intrinsicContentSize.height
        )

        valueLabel.isHidden = slider.value == slider.maximumValue || slider.value == slider.minimumValue

        valueDidChangeObservable.onNext(slider.value)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
