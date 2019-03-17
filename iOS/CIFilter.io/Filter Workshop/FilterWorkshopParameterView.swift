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
        case slider(min: Float, max: Float)
        case number(min: Float?, max: Float?, defaultValue: Float?)
        case integer(min: Int?, max: Int?, defaultValue: Int?)
        case vector(defaultValue: CIVectorCodableWrapper?)
        case color(defaultValue: CIColor)
        case boolean
        case freeformString
        case freeformStringAsData
    }

    let valueDidChangeObservable = ReplaySubject<Any>.create(bufferSize: 1)

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
        nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.addArrangedSubview(informationLabel)
        stackView.addArrangedSubview(descriptionLabel)
        nameLabel.text = parameter.name
        descriptionLabel.text = parameter.descriptionOrDefault
        informationLabel.text = parameter.type.informationalDescription

        nameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 360).isActive = true

        switch type {
        case .boolean:
            let uiSwitch = UISwitch()
            stackView.addArrangedSubview(uiSwitch)
            let behaviorSubject = BehaviorSubject(value: false)
            uiSwitch.rx.isOn.subscribe(behaviorSubject).disposed(by: bag)
            behaviorSubject.map { $0 ? 1 : 0 }.subscribe(self.valueDidChangeObservable).disposed(by: bag)
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
            colorInput.valueDidChange.subscribe(onNext: { vector in
                self.valueDidChangeObservable.onNext(vector)
            }).disposed(by: bag)
            stackView.addArrangedSubview(colorInput)
        case .freeformString:
            let numericInput = FreeformTextInput()
            numericInput.valueDidChange.subscribe(onNext: { string in
                self.valueDidChangeObservable.onNext(string)
            }).disposed(by: bag)
            stackView.addArrangedSubview(numericInput)
        case .freeformStringAsData:
            let numericInput = FreeformTextInput()
            numericInput.valueDidChange.subscribe(onNext: { string in
                self.valueDidChangeObservable.onNext(string.data(using: .utf8)!)
            }).disposed(by: bag)
            stackView.addArrangedSubview(numericInput)
        }

        stackView.edgesToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
