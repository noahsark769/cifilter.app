//
//  AsyncFilterApplicator.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/26/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import Foundation
import RxSwift

struct ParameterValue {
    let name: String
    let value: Any
}

/**
 * Accepts subscriptions for updating filter parameters and generating an output image async.
 */
final class AsyncFilterApplicator {
    enum Error: Swift.Error {
        case generationFailed // Catch-all for CIFilter errors - image could not be generated from filter.outputImage
        case implementationError(message: String)
        case needsMoreParameters(names: [String])
    }

    enum Event {
        case generationStarted
        case generationCompleted(image: UIImage)
        case generationErrored(error: Error)
    }

    let events = PublishSubject<Event>()

    private var bag = DisposeBag()
    private var currentFilter: FilterInfo? = nil
    private var currentParameterConfiguration = [String: Any]()
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()

    func set(filter: FilterInfo) {
        self.currentFilter = filter
        bag = DisposeBag() // dispose all current subscriptions
    }

    func set(value: Any, forParameterName name: String) {
        self.currentParameterConfiguration[name] = value
    }

    func addSubscription(for observable: Observable<ParameterValue>) {
        observable.throttle(0.3, scheduler: MainScheduler.instance).subscribe(onNext: { value in
            self.currentParameterConfiguration[value.name] = value.value
            self.generateOutputImageIfPossible()
        }).disposed(by: bag)
    }

    private func generateOutputImageIfPossible() {
        guard let filter = self.currentFilter else {
            events.onNext(.generationErrored(error: .implementationError(message: "No filter name provided")))
            return
        }
        let ciFilter = CIFilter(name: filter.name)!
        var stillNeededParameterNames = [String]()
        for parameter in filter.parameters {
            guard let value = self.currentParameterConfiguration[parameter.name] else {
                stillNeededParameterNames.append(parameter.name)
                continue
            }
            ciFilter.setValue(value, forKey: parameter.name)
        }
        if stillNeededParameterNames.count > 0 {
            events.onNext(.generationErrored(error: .needsMoreParameters(names: stillNeededParameterNames)))
        } else {
            queue.cancelAllOperations()
            queue.addOperation {
                guard let outputImage = ciFilter.outputImage else {
                    self.events.onNext(.generationErrored(error: .generationFailed))
                    return
                }
                let context = CIContext(options: nil)
                guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                    self.events.onNext(.generationErrored(error: .implementationError(message: "Could not create cgImage from CIContext")))
                    return
                }
                self.events.onNext(.generationCompleted(image: UIImage(cgImage: cgImage)))
            }
            self.events.onNext(.generationStarted)
        }
    }
}
