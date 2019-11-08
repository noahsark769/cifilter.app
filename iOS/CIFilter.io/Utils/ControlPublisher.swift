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

final class ControlPublisher<T: UIControl>: Publisher {
    typealias ControlEvent = (control: UIControl, event: UIControl.Event)
    typealias Output = ControlEvent
    typealias Failure = Never

    let subject = PassthroughSubject<Output, Failure>()

    convenience init(control: UIControl, event: UIControl.Event) {
        self.init(control: control, events: [event])
    }

    init(control: UIControl, events: [UIControl.Event]) {
        for event in events {
            control.addTarget(self, action: #selector(controlAction), for: event)
        }
    }

    @objc private func controlAction(sender: UIControl, forEvent event: UIControl.Event) {
        subject.send(ControlEvent(control: sender, event: event))
    }

    func receive<S>(subscriber: S) where S :
        Subscriber,
        ControlPublisher.Failure == S.Failure,
        ControlPublisher.Output == S.Input {

            subject.receive(subscriber: subscriber)
    }
}

extension UIControl {
    func addControlEventsObserver(events: [UIControl.Event]) -> AnyPublisher<UIControl, Never> {
        return ControlPublisher(control: self, events: events).map { $0.control }.eraseToAnyPublisher()
    }
}
