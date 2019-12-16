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
    // https://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    func normalizedRotationImage() -> UIImage? {
        if (self.imageOrientation == .up) {
            return self;
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)

        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
