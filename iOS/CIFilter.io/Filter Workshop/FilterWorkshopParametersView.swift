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
import Combine

private final class RedView: UILabel {
    init(text: String) {
        super.init(frame: .zero)
        self.backgroundColor = .red
        self.heightAnchor <=> 60
        self.textColor = ColorCompatibility.label
        self.text = text
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func observableFrom<PublisherType: Publisher>(publisher: PublisherType) -> Observable<PublisherType.Output> {
    return Observable.create { observer in
        let cancellable = publisher.sink(receiveCompletion: { completion in
            switch completion {
            case let .failure(error):
                observer.onError(error)
            case .finished:
                observer.onCompleted()
            }
        }, receiveValue: { value in
            observer.onNext(value)
        })
        return Disposables.create {
            cancellable.cancel()
        }
    }
}

//extension Publisher {
//    func forward(to subject: PassthroughSubject<Self.Output, Self.Failure>) -> AnyCancellable {
//        return self.sink(receiveCompletion: { completion in
//            subject.send(completion: completion)
//        }, receiveValue: {
//            subject.send
//        })
//    }
//}

final class FilterWorkshopParametersView: UIStackView {
    private var disposeBag: DisposeBag? = nil
    private var cancellables = Set<AnyCancellable>()

    let didUpdateFilterParameters = BehaviorSubject<[String: Any]>(value: [:])
    let didChooseAddImage = PassthroughSubject<(String, CGRect), Never>()
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

    func set(parameters: [FilterParameterInfo]) {
        paramNamesToImageArtboards = [:]
        self.removeAllArrangedSubviews()
        disposeBag = DisposeBag()

        var observables: [Observable<ParameterValue>] = []
        for parameter in parameters.sorted(by: { first, second in
            return first.name < second.name
        }) {
            if let workshopParameterViewType = parameter.workshopParameterViewType {
                let parameterView = FilterWorkshopParameterView(
                    type: workshopParameterViewType,
                    parameter: parameter
                )
                observables.append(parameterView.valueDidChangeObservable.map {
                    ParameterValue(name: parameter.name, value: $0)
                })
                self.addArrangedSubview(parameterView)
            } else if parameter.isImageType {
                let imageArtboardView = ImageArtboardView(name: parameter.name, configuration: .input)
                self.addArrangedSubview(imageArtboardView)
                observables.append(observableFrom(publisher: imageArtboardView.didChooseImage.map { image in
                    guard let cgImage = image.cgImage else {
                        fatalError("WARNING could not generate CGImage from chosen UIImage")
                    }
                    return ParameterValue(name: parameter.name, value: CIImage(cgImage: cgImage))
                }))
                imageArtboardView.didChooseAdd
                    .map { (parameter.name, $0) }
                    .subscribe(self.didChooseAddImage)
                    .store(in: &self.cancellables)
                paramNamesToImageArtboards[parameter.name] = imageArtboardView
            } else {
                NonFatalManager.shared.log("UnknownParameterViewType", data: ["parameter_name": parameter.name, "class_type": parameter.classType])
                print("WARNING don't know how to process parameter type \(parameter.classType)")
                self.addArrangedSubview(RedView(text: "\(parameter.name): \(parameter.classType)"))
            }
        }
        Observable.combineLatest(observables) { values in
            var dict: [String: Any] = [:]
            for parameterValue in values {
                dict[parameterValue.name] = parameterValue.value
            }
            return dict
        }.subscribe(self.didUpdateFilterParameters).disposed(by: disposeBag!)
    }

    func setImage(_ image: UIImage, forParameterNamed name: String) {
        paramNamesToImageArtboards[name]?.set(image: image, reportOnSubject: true)
    }
}

extension FilterParameterInfo {
    var isImageType: Bool {
        switch self.type {
        case .image: return true
        case .gradientImage: return true
        default: return false
        }
    }

    var workshopParameterViewType: FilterWorkshopParameterView.ParameterType? {
        switch self.type {
        case .integer:
            return .integer(
                min: nil, max: nil, defaultValue: nil
            )
        case let .scalar(info):
            return .number(
                min: info.minValue, max: info.maxValue, defaultValue: info.defaultValue
            )
        case let .distance(info):
            return .number(
                min: info.minValue, max: info.maxValue, defaultValue: info.defaultValue
            )
        case let .angle(info):
            return .number(
                min: info.minValue, max: info.maxValue, defaultValue: info.defaultValue
            )
        case let .unspecifiedNumber(info):
            return .number(
                min: info.minValue, max: info.maxValue, defaultValue: info.defaultValue
            )
        case let .count(info):
            return .integer(
                min: info.minValue, max: info.maxValue, defaultValue: info.defaultValue
            )
        case let .position(info):
            return .vector(
                defaultValue: info.defaultValue
            )
        case let .position3(info):
            return .vector(
                defaultValue: info.defaultValue
            )
        case let .rectangle(info):
            return .vector(
                defaultValue: info.defaultValue
            )
        case let .offset(info):
            return .vector(
                defaultValue: info.defaultValue
            )
        case let .unspecifiedVector(info):
            return .vector(
                defaultValue: info.defaultValue
            )
        case let .color(info):
            return .color(
                defaultValue: info.defaultValue
            )
        case let .opaqueColor(info):
            return .color(
                defaultValue: info.defaultValue
            )
        case .time:
            return .slider(min: 0, max: 1)
        case .boolean:
            return .boolean
        case .data:
            return .freeformStringAsData
        case .string:
            return .freeformString
        case .unspecifiedObject:
            if self.name == "inputColorSpace" {
                return .colorSpace
            }
            if let description = self.description, description.contains("CGColorSpace") {
                return .colorSpace
            }
            return nil
        default:
            return nil
        }
    }
}
