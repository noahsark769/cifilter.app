//
//  ActivityIndicator.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 6/26/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import Foundation
import SwiftUI

// From SwiftUIX

/// A view that shows that a task is in progress.
public struct ActivityIndicator {
    public enum Style {
        case medium
        case large
    }

    private var isAnimated: Bool = true
    private var style: Style?

    public init(style: Style) {
        self.style = style
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import UIKit

extension ActivityIndicator: UIViewRepresentable {
    public typealias Context = UIViewRepresentableContext<Self>
    public typealias UIViewType = UIActivityIndicatorView

    public func makeUIView(context: Context) -> UIViewType {
        UIActivityIndicatorView(style: .medium)
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        isAnimated ? uiView.startAnimating() : uiView.stopAnimating()

        if let style = style {
            uiView.style = .init(style)
        }
    }
}

#elseif os(macOS)

import Cocoa
import AppKit

extension ActivityIndicator: NSViewRepresentable {
    public typealias Context = NSViewRepresentableContext<Self>
    public typealias NSViewType = NSProgressIndicator

    public func makeNSView(context: Context) -> NSViewType {
        let nsView = NSProgressIndicator()

        nsView.isIndeterminate = true
        nsView.style = .spinning

        return nsView
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) {
        isAnimated ? nsView.startAnimation(self) : nsView.stopAnimation(self)
    }
}

#endif

// MARK: - Helpers -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIActivityIndicatorView.Style {
    public init(_ style: ActivityIndicator.Style) {
        switch style {
            case .medium:
                self = .medium
            case .large:
                self = .large
        }
    }
}

#endif
