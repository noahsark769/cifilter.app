//
//  Autolayout.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/28/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

infix operator <=>: MultiplicationPrecedence
@discardableResult public func <=>(left: NSLayoutXAxisAnchor, right: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
    let constraint = left.constraint(equalTo: right)
    constraint.isActive = true
    return constraint
}
@discardableResult public func <=>(left: NSLayoutYAxisAnchor, right: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
    let constraint = left.constraint(equalTo: right)
    constraint.isActive = true
    return constraint
}

infix operator --: AdditionPrecedence
infix operator ++: AdditionPrecedence
extension NSLayoutConstraint {
    @discardableResult static func ++(left: NSLayoutConstraint, right: CGFloat) -> NSLayoutConstraint {
        left.constant = right
        return left
    }

    @discardableResult static func --(left: NSLayoutConstraint, right: CGFloat) -> NSLayoutConstraint {
        left.constant = -right
        return left
    }
}

extension UIView {
    func edges(to view: UIView, insets: UIEdgeInsets = .zero) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor <=> view.leadingAnchor ++ insets.left
        self.trailingAnchor <=> view.trailingAnchor -- insets.right
        self.topAnchor <=> view.topAnchor ++ insets.top
        self.bottomAnchor <=> view.bottomAnchor -- insets.bottom
    }

    func edgesToSuperview(insets: UIEdgeInsets = .zero) {
        guard let superview = self.superview else { return }
        self.edges(to: superview, insets: insets)
    }
}
