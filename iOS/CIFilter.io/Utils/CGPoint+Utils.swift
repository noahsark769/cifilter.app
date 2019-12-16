//
//  CGPoint+Utils.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/17/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    func offsetX(by: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + by, y: self.y)
    }

    func offsetY(by: CGFloat) -> CGPoint {
        return CGPoint(x: self.x, y: self.y + by)
    }

    func isInside(circleWithRadius radius: CGFloat, centeredAt center: CGPoint) -> Bool {
        return pow(self.x - center.x, 2) + pow(self.y - center.y, 2) <= pow(radius, 2)
    }
}
