//
//  UIImage+Utils.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 3/2/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit
import CoreImage

struct RenderingResult {
    let image: UIImage
    let wasCropped: Bool
}

extension RenderingResult {
    init?(renderingFrom ciImage: CIImage, maximumExtent: CGRect) {
        let context = CIContext()
        var imageToRender = ciImage
        var wasCropped = false
        if imageToRender.extent.isInfinite {
            imageToRender = imageToRender.cropped(to: maximumExtent)
            wasCropped = true
        }
        self.wasCropped = wasCropped
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        self.image = UIImage(cgImage: cgImage)
    }
}

extension UIImage {
    static func renderingFrom(ciImage: CIImage, maximumExtent: CGRect) -> (UIImage, Bool)? {
        let context = CIContext()
        var imageToRender = ciImage
        var wasCropped = false
        if imageToRender.extent.isInfinite {
            imageToRender = imageToRender.cropped(to: maximumExtent)
            wasCropped = true
        }
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return (UIImage(cgImage: cgImage), wasCropped)
    }
}
