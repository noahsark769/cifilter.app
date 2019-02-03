//
//  BuiltInImage.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 2/2/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

struct BuiltInImage {
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

    private init(name: String, useCheckerboard: Bool = false) {
        let uiImage = UIImage(named: name)!
        image = uiImage
        if useCheckerboard {
            let ciImage = CIImage(image: uiImage)!
            let checkerboard = BuiltInImage.checkerboardFilter.outputImage!
            BuiltInImage.sourceOverCompositingFilter.setDefaults()
            BuiltInImage.sourceOverCompositingFilter.setValue(checkerboard, forKey: kCIInputBackgroundImageKey)
            BuiltInImage.sourceOverCompositingFilter.setValue(ciImage, forKey: kCIInputImageKey)
            let context = CIContext()
            let outputImage = BuiltInImage.sourceOverCompositingFilter.outputImage!
            guard let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else {
                fatalError("Could not create built in image from ciContext")
            }
            imageForImageChooser = UIImage(cgImage: cgImage)
        } else {
            imageForImageChooser = uiImage
        }
    }

    private init(name: String, generator: () -> (CIImage, CGRect)) {
        let context = CIContext()
        let (ciImage, extent) = generator()
        guard let cgImage = context.createCGImage(ciImage, from: extent) else {
            fatalError("Could not create built in image from ciContext")
        }
        let image = UIImage(cgImage: cgImage)
        imageForImageChooser = image
        self.image = image
    }

    static let knighted = BuiltInImage(name: "knighted")
    static let liberty = BuiltInImage(name: "liberty")
    static let paper = BuiltInImage(name: "paper", useCheckerboard: true)
    static let playhouse = BuiltInImage(name: "playhouse", useCheckerboard: true)
    static let black = BuiltInImage(name: "black", generator: {
        BuiltInImage.constantColorFilter.setDefaults()
        BuiltInImage.constantColorFilter.setValue(CIColor.black, forKey: "inputColor")
        let ciImage = BuiltInImage.constantColorFilter.outputImage!
        return (ciImage, CGRect(origin: .zero, size: CGSize(width: 500, height: 500)))
    });

    static let all: [BuiltInImage] = [
        .knighted,
        .liberty,
        .paper,
        .playhouse,
        .black
    ]
}
