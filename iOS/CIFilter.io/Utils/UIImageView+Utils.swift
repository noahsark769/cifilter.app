//
//  UIImageView+Utils.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/17/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

extension UIImageView {
    // From https://stackoverflow.com/questions/12770181/how-to-get-the-pixel-color-on-touch
    func getPixelColorAt(point: CGPoint) -> UIColor {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(
            data: pixel,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        )

        context!.translateBy(x: -point.x, y: -point.y)
        layer.render(in: context!)
        let color = UIColor(
            red: CGFloat(pixel[0]) / 255.0,
            green: CGFloat(pixel[1]) / 255.0,
            blue: CGFloat(pixel[2]) / 255.0,
            alpha: CGFloat(pixel[3]) / 255.0
        )

        pixel.deallocate()
        return color
    }

    func pointOnColorWheel(for color: UIColor) -> CGPoint? {
        guard let image = self.image else { return nil }

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)

        let width = self.frame.size.width
        let radius = width / 2
        let colorRadius = saturation * radius
        let angle = (1 - hue) * (2 * CGFloat.pi)
        let midX = width / 2
        let midY = self.frame.size.height / 2
        let xOffset = cos(angle) * colorRadius
        let yOffset = sin(angle) * colorRadius
        return CGPoint(x: midX + xOffset, y: midY + yOffset)
    }
}
