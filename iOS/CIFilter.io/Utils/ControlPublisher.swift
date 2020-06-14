//
//  ControPublisher.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/8/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation
import Combine
import UIKit

final class ControlPublisher<ControlType: UIControl>: NSObject, Publisher {
    typealias ControlEvent = (control: ControlType, event: UIControl.Event)
    typealias Output = ControlEvent
    typealias Failure = Never

    let subject = PassthroughSubject<Output, Failure>()

    convenience init(control: ControlType, event: UIControl.Event) {
        self.init(control: control, events: [event])
    }

    init(control: ControlType, events: [UIControl.Event]) {
        super.init()
        for event in events {
            control.addTarget(self, action: #selector(controlAction), for: event)
        }
    }

    @objc private func controlAction(sender: UIControl, forEvent event: UIControl.Event) {
        guard let control = sender as? ControlType else { return }
        subject.send(ControlEvent(control: control, event: event))
    }

    func receive<S>(subscriber: S) where S :
        Subscriber,
        ControlPublisher.Failure == S.Failure,
        ControlPublisher.Output == S.Input {
            subject.subscribe(subscriber)
    }
}

protocol ControlEventsObservable {}
extension UIControl: ControlEventsObservable {}

protocol ControlValueReporting {
    associatedtype ValueType

    var value: ValueType { get }
}

extension ControlEventsObservable where Self: UIControl {
    func addControlEventsObserver(events: [UIControl.Event]) -> AnyPublisher<Self, Never> {
        return ControlPublisher(control: self, events: events).map {
            $0.control
        }.eraseToAnyPublisher()
    }
}

extension ControlValueReporting where Self: UIControl {
    func addValueChangedObserver() -> AnyPublisher<ValueType, Never> {
        return self.addControlEventsObserver(events: [.valueChanged]).map {
            $0.value
        }.eraseToAnyPublisher()
    }
}
