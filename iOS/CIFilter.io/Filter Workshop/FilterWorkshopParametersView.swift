//
//  FilterWorkshopParametersView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/23/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AloeStackView

private final class RedView: UILabel {
    init(text: String) {
        super.init(frame: .zero)
        self.backgroundColor = .red
        self.heightAnchor <=> 60
        self.textColor = .white
        self.text = text
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class FilterWorkshopParametersView: UIStackView {
    var disposeBag: DisposeBag? = nil
    private let updateParameterSubject = PublishSubject<ParameterValue>()
    lazy var didUpdateParameter: ControlEvent<ParameterValue> = {
        return ControlEvent<ParameterValue>(events: updateParameterSubject)
    }()
    let didChooseAddImage = PublishSubject<(String, UIView)>()
    private var paramNamesToImageArtboards: [String: ImageArtboardView] = [:]
    init() {
        super.init(frame: .zero)
        self.axis = .vertical
        self.spacing = 50
        self.alignment = .leading
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: Having all these functions which do basically the same thing with different parameter types
    // is super hacky. Ideally, we'd have FilterParameterType itself be able to generate an applicable
    // FilterWorkshopParameterView.ParameterType
    private func addViewsAndSubscriptions(for info: FilterNumberParameterInfo<Float>, parameter: FilterParameterInfo) {
        let parameterView = FilterWorkshopParameterView(
            type: .number(
                min: info.minValue, max: info.maxValue, defaultValue: info.defaultValue
            ),
            parameter: parameter
        )
        parameterView.valueDidChange.subscribe(onNext: { value in
            self.updateParameterSubject.onNext(
                ParameterValue(name: parameter.name, value: value)
            )
        }).disposed(by: disposeBag!)
        self.addArrangedSubview(parameterView)
    }

    private func addViewsAndSubscriptions(for info: FilterNumberParameterInfo<Int>, parameter: FilterParameterInfo, isBoolean: Bool = false) {
        let type: FilterWorkshopParameterView.ParameterType = isBoolean ? .boolean : .integer(
            min: info.minValue, max: info.maxValue, defaultValue: info.defaultValue
        )
        let parameterView = FilterWorkshopParameterView(
            type: type,
            parameter: parameter
        )
        parameterView.valueDidChange.bind(to: <#T##(ControlEvent<Any>) -> R#>) .subscribe(onNext: { value in
            self.updateParameterSubject.onNext(
                ParameterValue(name: parameter.name, value: value)
            )
        }).disposed(by: disposeBag!)
        self.addArrangedSubview(parameterView)
    }

    private func addViewsAndSubscriptions(for info: FilterVectorParameterInfo, parameter: FilterParameterInfo) {
        let parameterView = FilterWorkshopParameterView(
            type: .vector(
                defaultValue: info.defaultValue
            ),
            parameter: parameter
        )
        parameterView.valueDidChange.subscribe(onNext: { value in
            self.updateParameterSubject.onNext(
                ParameterValue(name: parameter.name, value: value)
            )
        }).disposed(by: disposeBag!)
        self.addArrangedSubview(parameterView)
    }

    private func addViewsAndSubscriptions(for info: FilterColorParameterInfo, parameter: FilterParameterInfo) {
        let parameterView = FilterWorkshopParameterView(
            type: .color(
                defaultValue: info.defaultValue
            ),
            parameter: parameter
        )
        parameterView.valueDidChange.subscribe(onNext: { value in
            self.updateParameterSubject.onNext(
                ParameterValue(name: parameter.name, value: value)
            )
        }).disposed(by: disposeBag!)
        self.addArrangedSubview(parameterView)
    }

    private func addViewsAndSubscriptions(for info: FilterTimeParameterInfo, parameter: FilterParameterInfo) {
        let parameterView = FilterWorkshopParameterView(
            type: .slider(
                min: 0, max: 1
            ),
            parameter: parameter
        )
        parameterView.valueDidChange.subscribe(onNext: { value in
            self.updateParameterSubject.onNext(
                ParameterValue(name: parameter.name, value: value)
            )
        }).disposed(by: disposeBag!)
        self.addArrangedSubview(parameterView)
    }

    private func addViewsAndSubscriptions(for info: FilterDataParameterInfo, parameter: FilterParameterInfo) {
        let parameterView = FilterWorkshopParameterView(
            type: .freeformStringAsData,
            parameter: parameter
        )
        parameterView.valueDidChange.subscribe(onNext: { value in
            self.updateParameterSubject.onNext(
                ParameterValue(name: parameter.name, value: value)
            )
        }).disposed(by: disposeBag!)
        self.addArrangedSubview(parameterView)
    }

    private func addViewsAndSubscriptions(for info: FilterStringParameterInfo, parameter: FilterParameterInfo) {
        let parameterView = FilterWorkshopParameterView(
            type: .freeformString,
            parameter: parameter
        )
        parameterView.valueDidChange.subscribe(onNext: { value in
            self.updateParameterSubject.onNext(
                ParameterValue(name: parameter.name, value: value)
            )
        }).disposed(by: disposeBag!)
        self.addArrangedSubview(parameterView)
    }

    func set(parameters: [FilterParameterInfo]) {
        paramNamesToImageArtboards = [:]
        self.removeAllArrangedSubviews()
        disposeBag = DisposeBag()
        for parameter in parameters.sorted(by: { first, second in
            return first.name < second.name
        }) {
            switch parameter.type {
            case .image: fallthrough
            case .gradientImage:
                let imageArtboardView = ImageArtboardView(name: parameter.name, configuration: .input)
                self.addArrangedSubview(imageArtboardView)
                imageArtboardView.didChooseImage.subscribe(onNext: { image in
                    guard let cgImage = image.cgImage else {
                        print("WARNING could not generate CGImage from chosen UIImage")
                        return
                    }
                    self.updateParameterSubject.onNext(
                        ParameterValue(name: parameter.name, value: CIImage(cgImage: cgImage))
                    )
                }).disposed(by: disposeBag!)
                imageArtboardView.didChooseAdd.subscribe(onNext: { view in
                    self.didChooseAddImage.onNext((parameter.name, view))
                }).disposed(by: disposeBag!)
                paramNamesToImageArtboards[parameter.name] = imageArtboardView
            case let .scalar(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .distance(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .angle(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .unspecifiedNumber(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .count(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .position(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .position3(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .rectangle(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .offset(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .unspecifiedVector(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .color(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .opaqueColor(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .time(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .boolean(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter, isBoolean: true)
            case let .data(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .string(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            default:
                print("WARNING don't know how to process parameter type \(parameter.classType)")
                self.addArrangedSubview(RedView(text: "\(parameter.name): \(parameter.classType)"))
            }
        }
    }

    func setImage(_ image: UIImage, forParameterNamed name: String) {
        paramNamesToImageArtboards[name]?.set(image: image, reportOnSubject: true)
    }
}
