//
//  ImageChooserSwiftUIView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 8/4/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import SwiftUI
import Combine
import ColorCompatibility
//import SwiftUIX

struct ButtonFramePreferenceKey: PreferenceKey {
    typealias Value = CGRect?

    static var defaultValue: CGRect? = nil

    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = nextValue()
    }
}

struct AddImageView: View {
    typealias TapCallback = (CGRect) -> Void

    let didTap: TapCallback
    @State private var currentTapFrame: CGRect? = nil

    init(didTap: @escaping TapCallback) {
        self.didTap = didTap
    }

    var body: some View {
        ZStack {
            HStack(alignment: .lastTextBaseline) {
                Image(systemName: "square.and.arrow.down")
                    .foregroundColor(.white)
                    .padding(.trailing, 10)
                    .rotationEffect(.degrees(-90))
                    .offset(x: -4, y: -4)
                Text("Add Image")
                    .foregroundColor(.white)
            }.padding()
                .background(
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundColor(.blue)
                            .preference(key: ButtonFramePreferenceKey.self, value: geometry.frame(in: .global))
                    }
                ).onPreferenceChange(ButtonFramePreferenceKey.self, perform: { frame in
                    self.currentTapFrame = frame
                })
                .onTapGesture {
                    guard let frame = self.currentTapFrame else {
                        return
                    }
                    self.didTap(frame)
                }
        }
    }
}

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
        UIActivityIndicatorView(style: .white)
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
                self = .white
            case .large:
                self = .whiteLarge
        }
    }
}

#endif


struct BuiltInImageCarouselItemView: View {
    @State var loadingState: BuiltInImageManager.LoadingState = .loading
    var type: BuiltInImageManager.ImageType
    var didTapImage: (BuiltInImage) -> Void

    static let imageSize: CGFloat = 130
    static let imageSpacing: CGFloat = 20

    private var loadingView: AnyView? {
        guard case .loading = self.loadingState else {
            return nil
        }
        return ActivityIndicator(style: .medium)
            .frame(
                width: Self.imageSize,
                height: Self.imageSize
            )
            .background(Color(ColorCompatibility.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .erase()
    }

    private var imageView: AnyView? {
        guard case let .loaded(image) = self.loadingState else {
            return nil
        }
        return Image(uiImage: image.imageForImageChooser)
            .resizable()
            .scaledToFill()
            .frame(
                width: Self.imageSize,
                height: Self.imageSize
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .gesture(TapGesture().onEnded {
                self.didTapImage(image)
            })
            .erase()
    }

    var body: some View {
        return ZStack {
            self.loadingView
            self.imageView
        }.onReceive(BuiltInImageManager.shared.subject(forType: self.type)) { loadingState in
            self.loadingState = loadingState
        }
    }
}

struct BuiltInImageCarouselView: View {
    var didTapImage: (BuiltInImage) -> Void

    var body: some View {
        ScrollView([.horizontal]) {
            HStack(spacing: BuiltInImageCarouselItemView.imageSpacing) {
                ForEach(BuiltInImageManager.ImageType.allCases) { type in
                    BuiltInImageCarouselItemView(type: type, didTapImage: self.didTapImage)
                }
            }
        }.padding()
    }
}

struct ImageChooserSwiftUIView: View {
    static let size: CGFloat = 650

    let didTapAdd = PassthroughSubject<CGRect, Never>()
    let didTapImage = PassthroughSubject<BuiltInImage, Never>()

    var body: some View {
        VStack {
            AddImageView(didTap: { rect in
                self.didTapAdd.send(rect)
            }).frame(maxWidth: .infinity, maxHeight: .infinity)
            BuiltInImageCarouselView(didTapImage: { image in
                self.didTapImage.send(image)
            })
        }.frame(width: Self.size, height: Self.size)
        .clipped()
            .background(Color(ColorCompatibility.systemGray6))
            .cornerRadius(12)
    }
}

#if DEBUG
struct ImageChooserSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ImageChooserSwiftUIView()
    }
}
#endif
