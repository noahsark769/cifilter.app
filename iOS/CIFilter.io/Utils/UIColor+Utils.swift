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
        return string
    }
}

enum ColorCompatibility {
    static var label: UIColor {
        if #available(iOS 13, *) {
            return .label
        }
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    static var secondaryLabel: UIColor {
        if #available(iOS 13, *) {
            return .secondaryLabel
        }
        return UIColor(red: 0.9215686274509803, green: 0.9215686274509803, blue: 0.9607843137254902, alpha: 0.6)
    }
    static var tertiaryLabel: UIColor {
        if #available(iOS 13, *) {
            return .tertiaryLabel
        }
        return UIColor(red: 0.9215686274509803, green: 0.9215686274509803, blue: 0.9607843137254902, alpha: 0.3)
    }
    static var quaternaryLabel: UIColor {
        if #available(iOS 13, *) {
            return .quaternaryLabel
        }
        return UIColor(red: 0.9215686274509803, green: 0.9215686274509803, blue: 0.9607843137254902, alpha: 0.16)
    }
    static var systemFill: UIColor {
        if #available(iOS 13, *) {
            return .systemFill
        }
        return UIColor(red: 0.47058823529411764, green: 0.47058823529411764, blue: 0.5019607843137255, alpha: 0.36)
    }
    static var secondarySystemFill: UIColor {
        if #available(iOS 13, *) {
            return .secondarySystemFill
        }
        return UIColor(red: 0.47058823529411764, green: 0.47058823529411764, blue: 0.5019607843137255, alpha: 0.32)
    }
    static var tertiarySystemFill: UIColor {
        if #available(iOS 13, *) {
            return .tertiarySystemFill
        }
        return UIColor(red: 0.4627450980392157, green: 0.4627450980392157, blue: 0.5019607843137255, alpha: 0.24)
    }
    static var quaternarySystemFill: UIColor {
        if #available(iOS 13, *) {
            return .quaternarySystemFill
        }
        return UIColor(red: 0.4627450980392157, green: 0.4627450980392157, blue: 0.5019607843137255, alpha: 0.18)
    }
    static var placeholderText: UIColor {
        if #available(iOS 13, *) {
            return .placeholderText
        }
        return UIColor(red: 0.9215686274509803, green: 0.9215686274509803, blue: 0.9607843137254902, alpha: 0.3)
    }
    static var systemBackground: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        }
        return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    static var secondarySystemBackground: UIColor {
        if #available(iOS 13, *) {
            return .secondarySystemBackground
        }
        return UIColor(red: 0.10980392156862745, green: 0.10980392156862745, blue: 0.11764705882352941, alpha: 1.0)
    }
    static var tertiarySystemBackground: UIColor {
        if #available(iOS 13, *) {
            return .tertiarySystemBackground
        }
        return UIColor(red: 0.17254901960784313, green: 0.17254901960784313, blue: 0.1803921568627451, alpha: 1.0)
    }
    static var systemGroupedBackground: UIColor {
        if #available(iOS 13, *) {
            return .systemGroupedBackground
        }
        return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    static var secondarySystemGroupedBackground: UIColor {
        if #available(iOS 13, *) {
            return .secondarySystemGroupedBackground
        }
        return UIColor(red: 0.10980392156862745, green: 0.10980392156862745, blue: 0.11764705882352941, alpha: 1.0)
    }
    static var tertiarySystemGroupedBackground: UIColor {
        if #available(iOS 13, *) {
            return .tertiarySystemGroupedBackground
        }
        return UIColor(red: 0.17254901960784313, green: 0.17254901960784313, blue: 0.1803921568627451, alpha: 1.0)
    }
    static var separator: UIColor {
        if #available(iOS 13, *) {
            return .separator
        }
        return UIColor(red: 0.32941176470588235, green: 0.32941176470588235, blue: 0.34509803921568627, alpha: 0.6)
    }
    static var opaqueSeparator: UIColor {
        if #available(iOS 13, *) {
            return .opaqueSeparator
        }
        return UIColor(red: 0.2196078431372549, green: 0.2196078431372549, blue: 0.22745098039215686, alpha: 1.0)
    }
    static var link: UIColor {
        if #available(iOS 13, *) {
            return .link
        }
        return UIColor(red: 0.03529411764705882, green: 0.5176470588235295, blue: 1.0, alpha: 1.0)
    }
    static var darkText: UIColor {
        if #available(iOS 13, *) {
            return .darkText
        }
        return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    static var lightText: UIColor {
        if #available(iOS 13, *) {
            return .lightText
        }
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
    }
    static var systemBlue: UIColor {
        if #available(iOS 13, *) {
            return .systemBlue
        }
        return UIColor(red: 0.0392156862745098, green: 0.5176470588235295, blue: 1.0, alpha: 1.0)
    }
//    static var systemBrown: UIColor {
//        if #available(iOS 13, *) {
//            return .systemBrown
//        }
//        return UIColor(red: 0.6745098039215687, green: 0.5568627450980392, blue: 0.40784313725490196, alpha: 1.0)
//    }
    static var systemGreen: UIColor {
        if #available(iOS 13, *) {
            return .systemGreen
        }
        return UIColor(red: 0.18823529411764706, green: 0.8196078431372549, blue: 0.34509803921568627, alpha: 1.0)
    }
    static var systemIndigo: UIColor {
        if #available(iOS 13, *) {
            return .systemIndigo
        }
        return UIColor(red: 0.34509803921568627, green: 0.33725490196078434, blue: 0.8392156862745098, alpha: 1.0)
    }
    static var systemOrange: UIColor {
        if #available(iOS 13, *) {
            return .systemOrange
        }
        return UIColor(red: 1.0, green: 0.6235294117647059, blue: 0.0392156862745098, alpha: 1.0)
    }
    static var systemPink: UIColor {
        if #available(iOS 13, *) {
            return .systemPink
        }
        return UIColor(red: 1.0, green: 0.21568627450980393, blue: 0.37254901960784315, alpha: 1.0)
    }
    static var systemPurple: UIColor {
        if #available(iOS 13, *) {
            return .systemPurple
        }
        return UIColor(red: 0.7490196078431373, green: 0.35294117647058826, blue: 0.9490196078431372, alpha: 1.0)
    }
    static var systemRed: UIColor {
        if #available(iOS 13, *) {
            return .systemRed
        }
        return UIColor(red: 1.0, green: 0.27058823529411763, blue: 0.22745098039215686, alpha: 1.0)
    }
    static var systemTeal: UIColor {
        if #available(iOS 13, *) {
            return .systemTeal
        }
        return UIColor(red: 0.35294117647058826, green: 0.7843137254901961, blue: 0.9803921568627451, alpha: 1.0)
    }
    static var systemYellow: UIColor {
        if #available(iOS 13, *) {
            return .systemYellow
        }
        return UIColor(red: 1.0, green: 0.8392156862745098, blue: 0.0392156862745098, alpha: 1.0)
    }
    static var systemGray: UIColor {
        if #available(iOS 13, *) {
            return .systemGray
        }
        return UIColor(red: 0.5568627450980392, green: 0.5568627450980392, blue: 0.5764705882352941, alpha: 1.0)
    }
    static var systemGray2: UIColor {
        if #available(iOS 13, *) {
            return .systemGray2
        }
        return UIColor(red: 0.38823529411764707, green: 0.38823529411764707, blue: 0.4, alpha: 1.0)
    }
    static var systemGray3: UIColor {
        if #available(iOS 13, *) {
            return .systemGray3
        }
        return UIColor(red: 0.2823529411764706, green: 0.2823529411764706, blue: 0.2901960784313726, alpha: 1.0)
    }
    static var systemGray4: UIColor {
        if #available(iOS 13, *) {
            return .systemGray4
        }
        return UIColor(red: 0.22745098039215686, green: 0.22745098039215686, blue: 0.23529411764705882, alpha: 1.0)
    }
    static var systemGray5: UIColor {
        if #available(iOS 13, *) {
            return .systemGray5
        }
        return UIColor(red: 0.17254901960784313, green: 0.17254901960784313, blue: 0.1803921568627451, alpha: 1.0)
    }
    static var systemGray6: UIColor {
        if #available(iOS 13, *) {
            return .systemGray6
        }
        return UIColor(red: 0.10980392156862745, green: 0.10980392156862745, blue: 0.11764705882352941, alpha: 1.0)
    }
}

//enum UIColorCompatibility {
//    static var label: UIColor {
//
//    }
//    static var secondaryLabel: UIColor { return UIColor(rgb: 0xdddddd) }
//    static var tertiaryLabel: UIColor { return UIColor(rgb: 0x999999) }
//
//    static var systemBackground: UIColor { return .white }
//    static var secondarySystemBackground: UIColor { return UIColor(rgb: 0xeeeeee) }
//    static var quaternarySystemFill: UIColor { return UIColor(rgb: 0xdddddd) }
//}
//
//extension UIColor {
//
//}

@available(iOS, introduced: 11, obsoleted: 12)
extension UIActivityIndicatorView.Style {
    static var medium: UIActivityIndicatorView.Style { return .white }
    static var large: UIActivityIndicatorView.Style { return .whiteLarge }
}
