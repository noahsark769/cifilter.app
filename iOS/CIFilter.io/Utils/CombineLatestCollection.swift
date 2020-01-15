//
//  CombineLatestCollection.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/8/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Combine
import Foundation

// This is from: https://danieltull.co.uk//blog/2019/08/04/combine-latest-collection/

extension Collection where Element: Publisher {

    /// Combine the array of publishers to give a single publisher of an array
    /// of their outputs.
    public func combineLatest() -> CombineLatestCollection<Self> {
        return CombineLatestCollection(self)
    }
}

/// A `Publisher` that combines an array of publishers to provide an output of
/// an array of their respective outputs.
///
/// Changes will be sent if any of the publishers' values changes.
///
/// When any publisher fails, that will cause the failure of this publisher.
///
/// When all publishers complete successfully, that will cause the successful
/// completion of this publisher.
public struct CombineLatestCollection<Publishers>: Publisher
    where
    Publishers: Collection,
    Publishers.Element: Publisher
{
    public typealias Output = [Publishers.Element.Output]
    public typealias Failure = Publishers.Element.Failure

    private let publishers: Publishers
    public init(_ publishers: Publishers) {
        self.publishers = publishers
    }

    public func receive<Subscriber>(subscriber: Subscriber)
        where
        Subscriber: Combine.Subscriber,
        Subscriber.Failure == Failure,
        Subscriber.Input == Output
    {
        let subscription = Subscription(subscriber: subscriber,
                                        publishers: publishers)
        subscriber.receive(subscription: subscription)
        subscription.initializeSubscribers()
    }
}

extension CombineLatestCollection {

    /// A subscription for a CombineLatestCollection publisher.
    public final class Subscription<Subscriber>: Combine.Subscription
        where
        Subscriber: Combine.Subscriber,
        Subscriber.Failure == Publishers.Element.Failure,
        Subscriber.Input == Output
    {

        private var subscribers: [AnyCancellable] = []
        private let publishers: Publishers
        private var completions: Int = 0
        private let lock = NSLock()
        private var hasCompleted = false
        private let subscriber: Subscriber
        private var values: [Publishers.Element.Output?]

        fileprivate init(subscriber: Subscriber, publishers: Publishers) {
            self.values = Array(repeating: nil, count: publishers.count)
            self.subscriber = subscriber
            self.publishers = publishers
        }

        fileprivate func initializeSubscribers() {
            subscribers = publishers.enumerated().map { index, publisher in
                return publisher
                    .sink(receiveCompletion: { [weak self] completion in
                        guard let self = self else { return }
                        self.lock.lock()
                        defer { self.lock.unlock() }

                        guard case .finished = completion else {
                            // One failure in any of the publishers cause a
                            // failure for this subscription.
                            self.subscriber.receive(completion: completion)
                            self.hasCompleted = true
                            return
                        }

                        self.completions += 1

                        if self.completions == self.publishers.count {
                            self.subscriber.receive(completion: completion)
                            self.hasCompleted = true
                        }

                    }, receiveValue: { value in

                        self.lock.lock()
                        defer { self.lock.unlock() }

                        guard !self.hasCompleted else { return }

                        self.values[index] = value

                        // Get non-optional array of values and make sure we
                        // have a full array of values.
                        let current = self.values.compactMap { $0 }
                        if current.count == self.publishers.count {
                            _ = self.subscriber.receive(current)
                        }
                    })
            }
        }

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {
            subscribers.forEach { $0.cancel() }
        }
    }
}

