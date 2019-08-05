//
//  ImageChooserSwiftUIView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 8/4/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import SwiftUI
import Combine

struct AddImageView: View {
    let didTap: () -> Void

    var body: some View {
        Button(action: didTap) {
            HStack(alignment: .lastTextBaseline) {
                Image(systemName: "square.and.arrow.down")
                    .foregroundColor(.white)
                    .padding(.trailing, 10)
                    .rotationEffect(.degrees(-90))
                    .offset(x: -4, y: -4)
                Text("Add Image")
                    .foregroundColor(.white)
            }
        }.padding()
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(.blue)
            )
    }
}

struct BuiltInImageCarouselView: View {
    static let imageSize: CGFloat = 130
    static let imageSpacing: CGFloat = 20

    var didTapImage: (BuiltInImage) -> Void

    var body: some View {
        ScrollView([.horizontal]) {
            HStack(spacing: Self.imageSpacing) {
                ForEach(BuiltInImage.all) { image in
                    Image(uiImage: image.imageForImageChooser)
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
                }
            }
        }.padding()
    }
}

struct ImageChooserSwiftUIView: View {
    static let size: CGFloat = 650

    let didTapAdd = PassthroughSubject<Void, Never>()
    let didTapImage = PassthroughSubject<BuiltInImage, Never>()

    var body: some View {
        VStack {
            AddImageView(didTap: {
                self.didTapAdd.send()
            }).frame(maxWidth: .infinity, maxHeight: .infinity)
            BuiltInImageCarouselView(didTapImage: { image in
                self.didTapImage.send(image)
            })
        }.frame(width: Self.size, height: Self.size)
            .border(Color.gray, width: 1, cornerRadius: 12)
        .clipped()
            .background(Color(uiColor: .systemGray6))
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
