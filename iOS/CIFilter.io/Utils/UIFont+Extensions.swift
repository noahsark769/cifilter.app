//
//  UIFont+Extensions.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 10/6/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    static func monospacedHeaderFont() -> UIFont {
        if #available(iOS 13, *) {
            return Self.monospacedSystemFont(ofSize: 17, weight: .bold)
        } else {
            return UIFont(name: "Courier New", size: 17)!
        }
    }

    static func monospacedBodyFont() -> UIFont {
        if #available(iOS 13, *) {
            return Self.monospacedSystemFont(ofSize: 17, weight: .regular)
        } else {
            return UIFont(name: "Courier New", size: 17)!
        }
    }
}
