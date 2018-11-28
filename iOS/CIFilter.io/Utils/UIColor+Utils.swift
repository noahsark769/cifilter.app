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
}
