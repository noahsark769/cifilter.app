//
//  FilterWorkshopParameterView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/24/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift
import ColorCompatibility
import Combine

extension UISwitch: ControlValueReporting {
    var value: Bool {
        return self.isOn
    }
}

final class FilterWorkshopParameterView: UIView {
    private let bag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()
    enum ParameterType {
        case slider(min: Float, max: Float)
        case number(min: Float?, max: Float?, defaultValue: Float?)
        case integer(min: Int?, max: Int?, defaultValue: Int?)
        case vector(defaultValue: CIVectorCodableWrapper?)
        case color(defaultValue: CIColor)
        case boolean
        case freeformString
        case freeformStringAsData
        case colorSpace
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
        view.font = UIFont.monospacedHeaderFont()
        view.textColor = ColorCompatibility.label
        view.numberOfLines = 1
        return view
    }()

    private let descriptionLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.italicSystemFont(ofSize: 14)
        view.textColor = ColorCompatibility.label
        view.numberOfLines = 0
        return view
    }()

    private let informationLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = ColorCompatibility.label
        view.numberOfLines = 0
        return view
    }()

    private func furtherDetailLabel(text: String) -> UILabel {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = ColorCompatibility.label
        view.numberOfLines = 0
        view.text = text
        return view
    }

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

        let maxWidthAnchor = nameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 360)
        maxWidthAnchor.priority = .defaultHigh // not required since we want vector inputs widths to take priority
        maxWidthAnchor.isActive = true

        switch type {
        case .colorSpace:
            stackView.addArrangedSubview(self.furtherDetailLabel(text: "CIFilter.io does not support selecting color spaces. The device color space will be used."))
            let behaviorSubject = BehaviorSubject<CGColorSpace>(value: CGColorSpaceCreateDeviceRGB())
            behaviorSubject.map { $0 as Any }.subscribe(self.valueDidChangeObservable).disposed(by: bag)
        case .boolean:
            let uiSwitch = UISwitch()
            stackView.addArrangedSubview(uiSwitch)
            let subject: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
            uiSwitch.addValueChangedObserver()
                .subscribe(subject)
                .store(in: &self.cancellables)
            subject.map { $0 ? 1 : 0 }.sink { [weak self] value in
                self?.valueDidChangeObservable.onNext(value)
            }.store(in: &self.cancellables)
        case let .slider(min, max):
            let slider = NumericSlider(min: min, max: max)
            slider.widthAnchor <=> 400
            stackView.addArrangedSubview(slider)
            slider.addValueChangedObserver().sink { value in
                self.valueDidChangeObservable.onNext(value)
            }.store(in: &self.cancellables)
        case let .number(min, max, defaultValue):
            let numericInput = FreeformNumberInput(min: min, max: max, defaultValue: defaultValue)
            numericInput.addValueChangedObserver().compactMap { $0 }.sink { value in
                self.valueDidChangeObservable.onNext(value)
            }.store(in: &self.cancellables)
            stackView.addArrangedSubview(numericInput)
        case let .integer(min, max, defaultValue):
            let numericInput = FreeformNumberInput(min: min, max: max, defaultValue: defaultValue)
            numericInput.addValueChangedObserver().compactMap { $0 }.sink { value in
                self.valueDidChangeObservable.onNext(value)
            }.store(in: &self.cancellables)
            stackView.addArrangedSubview(numericInput)
        case let .vector(defaultValue):
            let lowercasedName = parameter.name.lowercased()
            let isRectangle = lowercasedName.contains("extent") || lowercasedName.contains("rectangle")
            let vectorInput = VectorInput(defaultValue: defaultValue, initialComponents: isRectangle ? 4 : 2)
            vectorInput.addValueChangedObserver().compactMap { $0 }.sink { value in
                self.valueDidChangeObservable.onNext(value)
            }.store(in: &self.cancellables)
            stackView.addArrangedSubview(vectorInput)
        case let .color(defaultValue):
            let colorInput = ColorInput(defaultValue:defaultValue)
            colorInput.addValueChangedObserver().sink { value in
                self.valueDidChangeObservable.onNext(value)
            }.store(in: &self.cancellables)
            stackView.addArrangedSubview(colorInput)
        case .freeformString:
            let input = FreeformTextInput()
            input.addValueChangedObserver().compactMap { $0 }.sink { value in
                self.valueDidChangeObservable.onNext(value)
            }.store(in: &self.cancellables)
            stackView.addArrangedSubview(input)
        case .freeformStringAsData:
            let input = FreeformTextInput()
            input.addValueChangedObserver().compactMap { $0 }.sink { value in
                self.valueDidChangeObservable.onNext(value)
            }.store(in: &self.cancellables)
            stackView.addArrangedSubview(input)
        }

        stackView.edgesToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
