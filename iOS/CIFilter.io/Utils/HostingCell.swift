//
//  HostingCell.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 7/1/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

final class HostingCell<Content: View>: UITableViewCell {
    private lazy var hostingController: UIHostingController<Content?> = UIHostingController(rootView: nil)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        hostingController.view.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func set(rootView: Content, parentController: UIViewController) {
        self.hostingController.rootView = rootView
        self.hostingController.view.invalidateIntrinsicContentSize()

        let requiresControllerMove = hostingController.parent != parentController
        if requiresControllerMove {
            parentController.addChild(hostingController)
        }

        if !self.contentView.subviews.contains(hostingController.view) {
            self.contentView.addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            hostingController.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            hostingController.view.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            hostingController.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        }

        if requiresControllerMove {
            hostingController.didMove(toParent: parentController)
        }
    }
}

//final class HostingCell<Content: View>: UITableViewCell {
//    private let hostingView: HostingView<Content?> = HostingView(rootView: nil)
//
//    var rootView: Content? {
//        get { hostingView.rootView }
//        set {
//            hostingView.rootView = newValue
////            hostingView.setNeedsLayout()
////            hostingView.layoutIfNeeded()
////            self.setNeedsLayout()
////            self.setNeedsUpdateConstraints()
//            self.invalidateIntrinsicContentSize()
//        }
//    }
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//
//        self.contentView.addSubview(hostingView)
//        hostingView.translatesAutoresizingMaskIntoConstraints = false
//        hostingView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
//        let trailing = hostingView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
//        trailing.priority = .required
//        trailing.isActive = true
//        hostingView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
//        let bottom = hostingView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
//        bottom.priority = .required
//        bottom.isActive = true
//
//        hostingView.setContentHuggingPriority(.required, for: .vertical)
//        hostingView.setContentHuggingPriority(.required, for: .horizontal)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
////        self.contentView.layoutIfNeeded()
//    }
//}
