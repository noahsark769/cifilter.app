//
//  AsyncFilterApplicator.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/26/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import Foundation
import Combine
import CoreImage
import UIKit

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
        case generationCompleted(image: RenderingResult, totalTime: TimeInterval, parameters: [String: Any])
        case generationErrored(error: Error)
    }

    let events = PassthroughSubject<Event, Never>()
    var timeStarted: TimeInterval? = nil

    private var cancellables = Set<AnyCancellable>()
    private var currentFilter: FilterInfo? = nil
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()

    func set(filter: FilterInfo) {
        self.currentFilter = filter
        cancellables = [] // dispose all current subscriptions
    }

    func addSubscription(for publisher: AnyPublisher<[String: Any], Never>) {
        publisher.debounce(for: .milliseconds(200), scheduler: RunLoop.main).sink { value in
            self.generateOutputImageIfPossible(parameterConfiguration: value)
        }.store(in: &self.cancellables)
    }

    func generateOutputImageIfPossible(parameterConfiguration: [String: Any]) {
        guard let filter = self.currentFilter else {
            events.send(.generationErrored(error: .implementationError(message: "No filter name provided")))
            return
        }
        let ciFilter = CIFilter(name: filter.name)!
        var stillNeededParameterNames = [String]()

        for parameter in filter.parameters {
            guard let value = parameterConfiguration[parameter.name] else {
                stillNeededParameterNames.append(parameter.name)
                continue
            }
            ciFilter.setValue(value, forKey: parameter.name)
        }
        if stillNeededParameterNames.count > 0 {
            events.send(.generationErrored(error: .needsMoreParameters(names: stillNeededParameterNames)))
        } else {
            queue.cancelAllOperations()

            let blockOperation = BlockOperation()
            blockOperation.addExecutionBlock { [weak blockOperation] in
                guard let op = blockOperation, !op.isCancelled else {
                    return
                }
                guard var outputImage = ciFilter.outputImage else {
                    self.events.send(.generationErrored(error: .generationFailed))
                    return
                }
                let context = CIContext(options: nil)

                var wasCropped = false
                if outputImage.extent.isInfinite {
                    outputImage = outputImage.cropped(to: CGRect(x: 0, y: 0, width: 500, height: 500))
                    wasCropped = true
                }

                guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                    self.events.send(.generationErrored(error: .implementationError(message: "Could not create cgImage from CIContext")))
                    return
                }
                guard !op.isCancelled else { return }
                self.events.send(.generationCompleted(
                    image: RenderingResult(image: UIImage(cgImage: cgImage), wasCropped: wasCropped),
                    totalTime: CACurrentMediaTime() - self.timeStarted!,
                    parameters: parameterConfiguration
                ))
            }
            queue.addOperation(blockOperation)
            self.events.send(.generationStarted)
            self.timeStarted = CACurrentMediaTime()
        }
    }
}
