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

open class HostingView<Content: View>: UIView {
    private let rootViewHostingController: UIHostingController<Content>

    public var rootView: Content {
        get {
            return rootViewHostingController.rootView
        } set {
            rootViewHostingController.rootView = newValue
            self.setNeedsLayout()
        }
    }

    public required init(rootView: Content) {
        self.rootViewHostingController = UIHostingController(rootView: rootView)

        super.init(frame: .zero)
        self.setupController()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupController() {
        rootViewHostingController.view.backgroundColor = .clear
        addSubview(rootViewHostingController.view)
        rootViewHostingController.view.edges(to: self)
    }
}
