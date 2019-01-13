//
//  ImageWorkshopConsoleView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/3/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

extension CGPoint {
    static func +(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

/**
 * A view which displays information about workshopping a filter to the user, including activity
 * inidcators and success/error messages.
 */
final class ImageWorkshopConsoleView: UIView {
    enum EventType {
        case showActivity(animated: Bool)
        case hideActivity(animated: Bool)
        case success(message: String, animated: Bool)
        case error(message: String)
    }

    private let activityIndicator = FilterApplicationIndicator()

    init() {
        super.init(frame: .zero)
//        self.axis = .horizontal
//        self.spacing = 10
//        self.alignment = .fill

        self.addSubview(activityIndicator)
//        activityIndicator.isHidden = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(for event: EventType) {
        switch event {
        case let .showActivity(animated):
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
//            activityIndicator.layer.opacity = 0
            activityIndicator.layoutIfNeeded()
            let lastPosition = activityIndicator.layer.position
            let offsetPosition = activityIndicator.layer.position + CGPoint(x: 40, y: 0)

            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 0
            opacityAnimation.toValue = 1
            opacityAnimation.duration = 1

            let positionAnimation = CABasicAnimation(keyPath: "position")
            positionAnimation.fromValue = offsetPosition
            positionAnimation.toValue = lastPosition
            positionAnimation.duration = 1

            let group = CAAnimationGroup()
            group.animations = [positionAnimation]

            activityIndicator.layer.add(group, forKey: "trans")
//            activityIndicator.layer.opacity = 1
            activityIndicator.layer.position = lastPosition

        case let .hideActivity(animated):
//            let block = {
//                self.activityIndicator.isHidden = true
//            }
//            if animated {
//                UIView.animate(withDuration: 0.3) {
//                    block()
//                }
//            } else {
//                block()
//            }
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        case let .success(message, animated):
            print("TPDO")
//            let messageView = ImageWorkshopConsoleMessageView(type: .success, message: message)
//            if animated {
//                messageView.isHidden = true
//            }
//            self.addArrangedSubview(messageView)
//            if animated {
//                UIView.animate(withDuration: 0.3) {
//                    messageView.isHidden = false
//                }
//            }
//            let anim = CAKeyframeAnimation()
//            anim.isAdditive = true
//
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
//                if animated {
//                    UIView.animate(withDuration: 0.3, animations: {
//                        messageView.isHidden = true
//                    }, completion: { _ in
//                        self.removeArrangedSubview(messageView)
//                        messageView.removeFromSuperview()
//                    })
//                } else {
//                    self.removeArrangedSubview(messageView)
//                    messageView.removeFromSuperview()
//                }
//            })
        case let .error(message):
            print("TODO")
//            let messageView = ImageWorkshopConsoleMessageView(type: .error, message: message)
//            self.addArrangedSubview(messageView)
        }
    }
}
