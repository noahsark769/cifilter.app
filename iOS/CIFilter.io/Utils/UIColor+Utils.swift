//
//  UIColor+Utils.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/28/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 256.0, green: CGFloat(green) / 256.0, blue: CGFloat(blue) / 256.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    // Adapted from https://gist.github.com/yannickl/16f0ed38f0698d9a8ae7, modified to accept alpha
    // values. Works with strings with or without "#", 6 char strings like "a735b5", 8 char strings
    // with alpha value like "836be64"
    convenience init?(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }

        let initialPosition = scanner.scanLocation
        var color: UInt32 = 0
        guard scanner.scanHexInt32(&color) else {
            return nil
        }
        let numCharsScanned = scanner.scanLocation - initialPosition
        guard numCharsScanned == 6 || numCharsScanned == 8 else {
            return nil
        }

        let alphaOffset = numCharsScanned == 8 ? 8 : 0
        let mask = 0x000000FF
        let r = Int(color >> (16 + alphaOffset)) & mask
        let g = Int(color >> (8 + alphaOffset)) & mask
        let b = Int(color >> (alphaOffset)) & mask

        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0

        let alpha: CGFloat
        if alphaOffset > 0 {
            let a = Int(color) & mask
            alpha = CGFloat(a) / 255.0
        } else {
            alpha = 1
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r*255) << 24 | (Int)(g*255) << 16 | (Int)(b*255) << 8 | (Int)(a*255) << 0

        let string = String(format:"#%08x", rgb)
        print("\(r) \(g) \(b) \(a)")
        print(string)
        return string
    }
}
