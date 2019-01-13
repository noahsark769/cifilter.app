//
//  Colors.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/2/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

enum Colors {
    case primary
    case availabilityBlue
    case availabilityRed
    case borderGray
    case successGreen

    var color: UIColor {
        switch self {
        case .primary: return UIColor(rgb: 0xF5BD5D)
        case .availabilityRed: return UIColor(rgb: 0xFF8D8D)
        case .availabilityBlue: return UIColor(rgb: 0x74AEDF)
        case .borderGray: return UIColor(rgb: 0xAFAFAF)
        case .successGreen: return UIColor(rgb: 0x8DCA83)
        }
    }
}
