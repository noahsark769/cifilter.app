//
//  Color+Utils.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 7/3/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {
    init(rgb: Int) {
        self.init(
            red: Double((rgb >> 24) & 0xFF) / 256,
            green: Double((rgb >> 16) & 0xFF) / 256,
            blue: Double((rgb >> 8) & 0xFF) / 256,
            opacity: Double(rgb & 0xFF) / 256
        )
    }

    init(uiColor: UIColor) {
        self.init(rgb: uiColor.toHex())
    }
}
