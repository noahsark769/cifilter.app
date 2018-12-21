//
//  FilterWorkshopContentView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/14/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

final class FilterWorkshopContentView: UIView {
    private let imageArtboardView = ImageArtboardView(name: "inputImage")
    private let outputImageArtboardView = ImageArtboardView(name: "outputImage")

    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(patternImage: UIImage(named: "workshop-background")!)
        self.addSubview(imageArtboardView)
        self.addSubview(outputImageArtboardView)

        // need to disable autoresizing mask for self since this view will be inside a scroll view,
        // and as such the superview will not be responsible for disabling its autoresizing mask
        [imageArtboardView, outputImageArtboardView, self].disableTranslatesAutoresizingMaskIntoConstraints()

        imageArtboardView.set(image: UIImage(named: "knighted")!)
        imageArtboardView.topAnchor <=> self.topAnchor ++ 100
        imageArtboardView.bottomAnchor <=> self.bottomAnchor -- 100
        outputImageArtboardView.topAnchor <=> self.topAnchor ++ 100
        outputImageArtboardView.bottomAnchor <=> self.bottomAnchor -- 100
        imageArtboardView.leadingAnchor <=> self.leadingAnchor ++ 100

        imageArtboardView.trailingAnchor <=> outputImageArtboardView.leadingAnchor -- 100
        outputImageArtboardView.trailingAnchor <=> self.trailingAnchor -- 100

        let filter = CIFilter(name: "CIThermal")!
        filter.setValue(CIImage(cgImage: UIImage(named: "knighted")!.cgImage!), forKey: kCIInputImageKey)
        let outputImage = UIImage(ciImage: filter.outputImage!)
        outputImageArtboardView.set(image: outputImage)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
