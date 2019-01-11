//
//  ImageWorkshopConsoleView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/3/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

/**
 * A view which displays information about workshopping a filter to the user, including activity
 * inidcators and success/error messages.
 */
final class ImageWorkshopConsoleView: UIStackView {
    enum EventType {
        case showActivity(animated: Bool)
        case hideActivity(animated: Bool)
        case success(message: String, animated: Bool)
        case error(message: String)
    }

    private let activityIndicator = FilterApplicationIndicator()

    init() {
        super.init(frame: .zero)
        self.axis = .horizontal
        self.spacing = 10
        self.alignment = .fill

        self.addArrangedSubview(activityIndicator)
        activityIndicator.isHidden = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(for event: EventType) {
        switch event {
        case let .showActivity(animated):
            let block: () -> Void = {
                self.activityIndicator.isHidden = false
            }
            if animated {
                UIView.animate(withDuration: 0.3) {
                    block()
                }
            } else {
                block()
            }
            activityIndicator.startAnimating()
        case let .hideActivity(animated):
            let block = {
                self.activityIndicator.isHidden = true
            }
            if animated {
                UIView.animate(withDuration: 0.3) {
                    block()
                }
            } else {
                block()
            }
            activityIndicator.stopAnimating()
        case let .success(message, animated):
            let messageView = ImageWorkshopConsoleMessageView(type: .success, message: message)
            if animated {
                messageView.isHidden = true
            }
            self.addArrangedSubview(messageView)
            if animated {
                UIView.animate(withDuration: 0.3) {
                    messageView.isHidden = false
                }
            }
            let anim = CAKeyframeAnimation()
            anim.isAdditive = true

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                if animated {
                    UIView.animate(withDuration: 0.3, animations: {
                        messageView.isHidden = true
                    }, completion: { _ in
                        self.removeArrangedSubview(messageView)
                        messageView.removeFromSuperview()
                    })
                } else {
                    self.removeArrangedSubview(messageView)
                    messageView.removeFromSuperview()
                }
            })
        case let .error(message):
            let messageView = ImageWorkshopConsoleMessageView(type: .error, message: message)
            self.addArrangedSubview(messageView)
        }
    }
}
