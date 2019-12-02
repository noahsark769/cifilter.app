//
//  GradientSliderView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/1/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import SwiftUI

struct GradientSliderView: View {
    @Binding var value: CGFloat
    @State var isDragging = false
    let width: CGFloat
    let height: CGFloat
    let sliderWidth: CGFloat
    private let image: UIImage

    init(value: Binding<CGFloat>, width: CGFloat, height: CGFloat, sliderWidth: CGFloat) {
        self._value = value
        self.width = width
        self.height = height
        self.sliderWidth = sliderWidth

        let filter = CIFilter.smoothLinearGradient()
        filter.color0 = CIColor.black
        filter.color1 = CIColor.white
        filter.point0 = CGPoint(x: 0, y: 0)
        filter.point1 = CGPoint(x: width, y: 0)
        let ciImage = filter.outputImage!
        let image = CIContext().createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: width, height: height))!
        self.image = UIImage(cgImage: image)
    }

    var gesture: some Gesture {
        return DragGesture(minimumDistance: 0)
            .onChanged { value in
                self.isDragging = true
                self.value = min(max(value.location.x / self.width, 0), 1)
            }
            .onEnded { _ in
                self.isDragging = false
            }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: self.sliderWidth / 2 + 10) {
                Image(uiImage: image)
                    .gesture(gesture)
                VStack(alignment: .leading) {
                    Text("\(Int(self.value * 100))%")
                    Text("Lightness")
                }.font(.caption)
                Spacer()
            }
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(hue: 0, saturation: 0, brightness: Double(value)))
                )
                .frame(width: self.sliderWidth * (self.isDragging ? 2 : 1), height: self.isDragging ? 80 : 40)
                .offset(x: self.width * value - (self.sliderWidth * (self.isDragging ? 2 : 1)) / 2, y: 0)
                .gesture(gesture)
        }
    }
}
