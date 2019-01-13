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
        case showActivity
        case hideActivity
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
        case .showActivity:
            self.activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        case .hideActivity:
            self.activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        case let .success(message, animated):
            let messageView = ImageWorkshopConsoleMessageView(type: .success, message: message)
            self.addArrangedSubview(messageView)
            if animated {
                messageView.alpha = 0
                messageView.transform = CGAffineTransform(translationX: 50, y: 0)

                UIView.animate(withDuration: 0.3) {
                    messageView.alpha = 1
                    messageView.transform = .identity
                }
            }

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                let removeBlock = {
                    self.removeArrangedSubview(messageView)
                    messageView.removeFromSuperview()
                }
                if animated {
                    UIView.animate(withDuration: 0.3, animations: {
                        messageView.transform = CGAffineTransform(translationX: -50, y: 0)
                        messageView.alpha = 0
                    }, completion: { _ in removeBlock() })
                } else {
                    removeBlock()
                }
            })
        case let .error(message):
            let messageView = ImageWorkshopConsoleMessageView(type: .error, message: message)
            self.addArrangedSubview(messageView)
        }
    }
}
