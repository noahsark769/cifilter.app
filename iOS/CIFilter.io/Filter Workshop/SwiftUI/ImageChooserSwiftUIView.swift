//
//  ImageChooserSwiftUIView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 8/4/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import SwiftUI
import Combine

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
            .background(Color(.systemGray5))
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
            .background(Color(.systemGray6))
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
