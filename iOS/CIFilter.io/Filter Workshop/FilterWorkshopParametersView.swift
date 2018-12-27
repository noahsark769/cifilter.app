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

final class FilterWorkshopParametersView: UIStackView {
    var disposeBag: DisposeBag? = nil
    private let updateParameterSubject = PublishSubject<ParameterValue>()
    lazy var didUpdateParameter: ControlEvent<ParameterValue> = {
        return ControlEvent<ParameterValue>(events: updateParameterSubject)
    }()
    init() {
        super.init(frame: .zero)
        self.axis = .vertical
        self.spacing = 50
        self.alignment = .leading
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addViewsAndSubscriptions(for info: FilterNumberParameterInfo<Float>, parameter: FilterParameterInfo) {
        if let sliderMin = info.sliderMin, let sliderMax = info.sliderMax {
            let parameterView = WorkshopParameterView(
                type: .slider(min: sliderMin, max: sliderMax),
                parameter: parameter
            )
            parameterView.valueDidChange.subscribe(onNext: { value in
                self.updateParameterSubject.onNext(
                    ParameterValue(name: parameter.name, value: value)
                )
            }).disposed(by: disposeBag!)
            self.addArrangedSubview(parameterView)
        } else {
            let parameterView = WorkshopParameterView(
                type: .number,
                parameter: parameter
            )
            parameterView.valueDidChange.subscribe(onNext: { value in
                self.updateParameterSubject.onNext(
                    ParameterValue(name: parameter.name, value: value)
                )
            }).disposed(by: disposeBag!)
            self.addArrangedSubview(parameterView)
        }
    }

    func set(parameters: [FilterParameterInfo]) {
        self.removeAllArrangedSubviews()
        disposeBag = DisposeBag()
        for parameter in parameters {
            switch parameter.type {
            case .image:
                let imageArtboardView = ImageArtboardView(name: parameter.name)
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
            case let .scalar(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            case let .distance(info):
                self.addViewsAndSubscriptions(for: info, parameter: parameter)
            default:
                print("WARNING don't know how to process parameter type \(parameter.classType)")
            }
        }
    }
}
