//
//  UIHostingView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 6/26/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

// From SwiftUIX
open class HostingView<Content: View>: UIView {
    private let rootViewHostingController: UIHostingController<Content>

    public var rootView: Content {
        get {
            return rootViewHostingController.rootView
        } set {
            rootViewHostingController.rootView = newValue
        }
    }

    public required init(rootView: Content) {
        self.rootViewHostingController = UIHostingController(rootView: rootView)

        super.init(frame: .zero)

        rootViewHostingController.view.backgroundColor = .clear

        addSubview(rootViewHostingController.view)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        rootViewHostingController.view.frame = self.bounds
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        rootViewHostingController.sizeThatFits(in: size)
    }

    override open func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        rootViewHostingController.sizeThatFits(in: targetSize)
    }
}
