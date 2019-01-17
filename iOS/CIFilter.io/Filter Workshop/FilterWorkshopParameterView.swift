//
//  FilterWorkshopParameterView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/24/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FilterWorkshopParameterView: UIView {
    private let bag = DisposeBag()
    enum ParameterType {
        /// Currently unused. See NumericSlider for explanation
        case slider(min: Float, max: Float)
        case number(min: Float?, max: Float?, defaultValue: Float?)
        case integer(min: Int?, max: Int?, defaultValue: Int?)
        case vector(defaultValue: CIVectorCodableWrapper?)
        case color(defaultValue: CIColor)
    }

    private let valueDidChangeObservable = PublishSubject<Any>()
    lazy var valueDidChange: ControlEvent<Any> = {
        return ControlEvent(events: valueDidChangeObservable)
    }()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()

    private let nameLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "Courier New", size: 17)
        view.numberOfLines = 1
        return view
    }()

    private let descriptionLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.italicSystemFont(ofSize: 14)
        view.textColor = UIColor(rgb: 0x666666)
        view.numberOfLines = 0
        return view
    }()

    private let informationLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = UIColor(rgb: 0x666666)
        view.numberOfLines = 0
        return view
    }()

    // TODO: I don't like passing in the parameter info AND the parameter type here. We should either
    // derive parameter type from paramter info OR pass in description, min/max, etc directly instead
    // of parameter info
    init(type: ParameterType, parameter: FilterParameterInfo) {
        super.init(frame: .zero)

        addSubview(stackView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(informationLabel)
        stackView.addArrangedSubview(descriptionLabel)
        nameLabel.text = parameter.name
        descriptionLabel.text = parameter.descriptionOrDefault
        informationLabel.text = parameter.type.informationalDescription

        nameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 360).isActive = true

        switch type {
        case let .slider(min, max):
            let slider = NumericSlider(min: min, max: max)
            slider.widthAnchor <=> 400
            stackView.addArrangedSubview(slider)
            slider.valueDidChange.subscribe(onNext: { float in
                self.valueDidChangeObservable.onNext(float)
            }).disposed(by: bag)
        case let .number(min, max, defaultValue):
            let numericInput = FreeformNumberInput(min: min, max: max, defaultValue: defaultValue)
            numericInput.valueDidChange.subscribe(onNext: { float in
                self.valueDidChangeObservable.onNext(float)
            }).disposed(by: bag)
            stackView.addArrangedSubview(numericInput)
        case let .integer(min, max, defaultValue):
            let numericInput = FreeformNumberInput(min: min, max: max, defaultValue: defaultValue)
            numericInput.valueDidChange.subscribe(onNext: { float in
                self.valueDidChangeObservable.onNext(float)
            }).disposed(by: bag)
            stackView.addArrangedSubview(numericInput)
        case let .vector(defaultValue):
            let vectorInput = VectorInput(defaultValue: defaultValue)
            vectorInput.valueDidChange.subscribe(onNext: { vector in
                self.valueDidChangeObservable.onNext(vector)
            }).disposed(by: bag)
            stackView.addArrangedSubview(vectorInput)
        case let .color(defaultValue):
            let colorInput = ColorInput(defaultValue:defaultValue)
            stackView.addArrangedSubview(colorInput)
        }

        stackView.edgesToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
