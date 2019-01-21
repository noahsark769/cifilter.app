//
//  CGPoint+Utils.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/17/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    func offset(from: CGPoint) -> CGPoint {
        return CGPoint(x: self.x - from.x, y: self.y - from.y)
    }
}
