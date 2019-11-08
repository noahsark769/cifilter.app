//
//  UITapGestureRecognizer+Combine.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/8/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation
import Combine
import UIKit

final class Target: NSObject {
    let didFire = PassthroughSubject<Void, Never>()

    @objc func fire() {
        didFire.send()
    }
}

final class CombineTapGestureRecognizer: UITapGestureRecognizer {
    fileprivate let target: Target

    init() {
        let target = Target()
        self.target = target
        super.init(target: target, action: #selector(Target.fire))
    }
}

final class CombinePanGestureRecognizer: UIPanGestureRecognizer {
    private var target: Target! = nil

    var strongDelegate: UIGestureRecognizerDelegate? = nil

    init() {
        let target = Target()
        super.init(target: target, action: #selector(Target.fire))
        self.target = target
    }

    func subscribe(_ receiveValue: @escaping (UIPanGestureRecognizer) -> Void) -> AnyCancellable {
        return self.target.didFire.sink(receiveValue: {
            receiveValue(self)
        })
    }
}

extension UIView {
    func addTapHandler(numberOfTapsRequired: Int = 1) -> AnyPublisher<UITapGestureRecognizer, Never> {
        self.isUserInteractionEnabled = true
        let recognizer = CombineTapGestureRecognizer()
        recognizer.numberOfTapsRequired = numberOfTapsRequired
        self.addGestureRecognizer(recognizer)
        return recognizer.target.didFire.map { recognizer }.eraseToAnyPublisher()
    }

    func addPanHandler(
        configure: (UIPanGestureRecognizer) -> Void = { _ in },
        delegate: ((UIPanGestureRecognizer) -> UIGestureRecognizerDelegate)? = nil
    ) -> CombinePanGestureRecognizer {
        self.isUserInteractionEnabled = true
        let recognizer = CombinePanGestureRecognizer()
        if let delegate = delegate?(recognizer) {
            recognizer.strongDelegate = delegate
            recognizer.delegate = delegate
        }
        configure(recognizer)
        self.addGestureRecognizer(recognizer)
        return recognizer
    }
}
