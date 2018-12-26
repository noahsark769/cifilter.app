//
//  WorkshopParameterView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/24/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WorkshopParameterView: UIView {
    private let bag = DisposeBag()
    enum ParameterType {
        case slider(min: Float, max: Float)
        case number
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
        view.numberOfLines = 1
        return view
    }()

    // TODO: I don't like passing in the parameter info AND the parameter type here. We should either
    // derive parameter type from paramter info OR pass in description, min/max, etc directly instead
    // of parameter info
    init(type: ParameterType, parameter: FilterParameterInfo) {
        super.init(frame: .zero)

        addSubview(stackView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(descriptionLabel)
        nameLabel.text = parameter.name
        descriptionLabel.text = parameter.descriptionOrDefault

        switch type {
        case let .slider(min, max):
            let slider = NumericSlider(min: min, max: max)
            slider.widthAnchor <=> 400
            stackView.addArrangedSubview(slider)
            slider.valueDidChange.throttle(0.3, scheduler: MainScheduler.instance).subscribe(onNext: { float in
                self.valueDidChangeObservable.onNext(float)
            }).disposed(by: bag)
        case .number:
            let numericInput = FreeformNumberInput()
            numericInput.valueDidChange.throttle(0.3, scheduler: MainScheduler.instance).subscribe(onNext: { float in
                self.valueDidChangeObservable.onNext(float)
            }).disposed(by: bag)
            stackView.addArrangedSubview(numericInput)
        }

        stackView.edgesToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
