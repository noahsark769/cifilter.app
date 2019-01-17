//
//  ColorInput.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/16/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

final class ColorInput: UIView {
    private let imageView = UIImageView()
    private let colorSpace = CGColorSpaceCreateDeviceRGB()

    init(defaultValue: CIColor) {
        // TODO: defaultValue is currently unused
        super.init(frame: .zero)
        let filter = CIFilter(name: "CIHueSaturationValueGradient", parameters: [
            "inputColorSpace": self.colorSpace,
            "inputDither": NSNumber(floatLiteral: 0),
            "inputRadius": NSNumber(integerLiteral: 100),
            "inputSoftness": NSNumber(integerLiteral: 0),
            "inputValue": NSNumber(integerLiteral: 1)
        ])!
        let image = UIImage(ciImage: filter.outputImage!)
        imageView.contentMode = .scaleAspectFill
        imageView.image = image

        addSubview(imageView)
        imageView.edgesToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
