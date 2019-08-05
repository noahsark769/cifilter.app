//
//  BuiltInImage.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 2/2/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

extension CIImage {
    func checkerboarded() -> CIImage {
        let checkerboardFilter = CIFilter(name: "CICheckerboardGenerator", parameters: [
            "inputWidth": 40,
            "inputColor0": CIColor.white,
            "inputColor1": CIColor(color: UIColor(rgb: 0xeeeeee)),
            "inputCenter": CIVector(x: 0, y: 0),
            "inputSharpness": 1
        ])!
        let sourceOverCompositingFilter = CIFilter(name: "CISourceOverCompositing")!
        sourceOverCompositingFilter.setValue(checkerboardFilter.outputImage!, forKey: kCIInputBackgroundImageKey)
        sourceOverCompositingFilter.setValue(self, forKey: kCIInputImageKey)
        return sourceOverCompositingFilter.outputImage!
    }
}

struct BuiltInImage: Identifiable {
    private(set) var id = UUID()

    let image: UIImage
    let imageForImageChooser: UIImage
    private static let checkerboardFilter = CIFilter(name: "CICheckerboardGenerator", parameters: [
        "inputWidth": 40,
        "inputColor0": CIColor.white,
        "inputColor1": CIColor(color: UIColor(rgb: 0xeeeeee)),
        "inputCenter": CIVector(x: 0, y: 0),
        "inputSharpness": 1
        ])!
    private static let sourceOverCompositingFilter = CIFilter(name: "CISourceOverCompositing")!
    private static let constantColorFilter = CIFilter(name: "CIConstantColorGenerator")!
    private static let linearGradientFilter = CIFilter(name: "CISmoothLinearGradient")!

    private init(name: String, useCheckerboard: Bool = false) {
        let uiImage = UIImage(named: name)!
        image = uiImage
        if useCheckerboard {
            let ciImage = CIImage(image: uiImage)!
            let outputImage = ciImage.checkerboarded()
            let context = CIContext()
            guard let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else {
                fatalError("Could not create built in image from ciContext")
            }
            imageForImageChooser = UIImage(cgImage: cgImage)
        } else {
            imageForImageChooser = uiImage
        }
    }

    private init(name: String, generator: () -> (CIImage, CIImage, CGRect)) {
        let context = CIContext()
        let (ciImage, ciImageForImageChooser, extent) = generator()
        guard let cgImage = context.createCGImage(ciImage, from: extent) else {
            fatalError("Could not create built in image from ciContext")
        }
        let image = UIImage(cgImage: cgImage)
        self.image = image

        guard let cgImageForChooser = context.createCGImage(ciImageForImageChooser, from: extent) else {
            fatalError("Could not create built in image from ciContext")
        }
        let imageForChooser = UIImage(cgImage: cgImageForChooser)
        self.imageForImageChooser = imageForChooser
    }

    static let knighted = BuiltInImage(name: "knighted")
    static let liberty = BuiltInImage(name: "liberty")
    static let shaded = BuiltInImage(name: "shadedsphere")
    static let paper = BuiltInImage(name: "paper", useCheckerboard: true)
    static let playhouse = BuiltInImage(name: "playhouse", useCheckerboard: true)
    // TODO(UIKitForMac): This makes everything crash, idk why
//    static let black = BuiltInImage(name: "black", generator: {
//        BuiltInImage.constantColorFilter.setDefaults()
//        BuiltInImage.constantColorFilter.setValue(CIColor.black, forKey: "inputColor")
//        let ciImage = BuiltInImage.constantColorFilter.outputImage!
//        return (ciImage, ciImage, CGRect(origin: .zero, size: CGSize(width: 500, height: 500)))
//    });
//    static let white = BuiltInImage(name: "white", generator: {
//        BuiltInImage.constantColorFilter.setDefaults()
//        BuiltInImage.constantColorFilter.setValue(CIColor.white, forKey: "inputColor")
//        let ciImage = BuiltInImage.constantColorFilter.outputImage!
//        return (ciImage, ciImage, CGRect(origin: .zero, size: CGSize(width: 500, height: 500)))
//    });
    static let gradient = BuiltInImage(name: "gradient", generator: {
        BuiltInImage.linearGradientFilter.setDefaults()
        BuiltInImage.linearGradientFilter.setValue(CIColor(red: 0, green: 0, blue: 0, alpha: 1), forKey: "inputColor0")
        BuiltInImage.linearGradientFilter.setValue(CIColor(red: 0, green: 0, blue: 0, alpha: 0), forKey: "inputColor1")
        BuiltInImage.linearGradientFilter.setValue(CIVector(x: 0, y: 250), forKey: "inputPoint0")
        BuiltInImage.linearGradientFilter.setValue(CIVector(x: 500, y: 250), forKey: "inputPoint1")
        let ciImage = BuiltInImage.linearGradientFilter.outputImage!
        return (ciImage, ciImage.checkerboarded(), CGRect(origin: .zero, size: CGSize(width: 500, height: 500)))
    });

    static let all: [BuiltInImage] = [
        .knighted,
        .liberty,
        .paper,
        .playhouse,
        .shaded,
        // TODO(UIKitForMac):
//        .black,
//        .white,
        .gradient
    ]
}
