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

    init(type: ParameterType, name: String) {
        super.init(frame: .zero)

        addSubview(stackView)
        stackView.addArrangedSubview(nameLabel)
        nameLabel.text = name

        switch type {
        case let .slider(min, max):
            let slider = NumericSlider(min: min, max: max)
            slider.widthAnchor <=> 400
            stackView.addArrangedSubview(slider)
            slider.valueDidChange.throttle(0.3, scheduler: MainScheduler.instance).subscribe(onNext: { float in
                self.valueDidChangeObservable.onNext(float)
            }).disposed(by: bag)
        }

        stackView.edgesToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
