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
    private let updateParameterSubject = PublishSubject<(String, Any)>()
    lazy var didUpdateParameter: ControlEvent<(String, Any)> = {
        return ControlEvent<(String, Any)>(events: updateParameterSubject)
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
                    self.updateParameterSubject.onNext((parameter.name, CIImage(cgImage: cgImage)))
                }).disposed(by: disposeBag!)
            case let .scalar(info):
                guard let sliderMin = info.sliderMin, let sliderMax = info.sliderMax else {
                    print("WARNING No slider min/max for \(parameter.name)")
                    continue
                }
                let parameterView = WorkshopParameterView(
                    type: .slider(min: sliderMin, max: sliderMax),
                    name: parameter.name
                )
                self.addArrangedSubview(parameterView)
            default:
                print("WARNING don't know how to process parameter type \(parameter.classType)")
            }
        }
    }
}
