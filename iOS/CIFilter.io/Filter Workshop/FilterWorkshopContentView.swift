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
//    private let imageArtboardView = ImageArtboardView(name: "inputImage")
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(patternImage: UIImage(named: "workshop-background")!)
        self.addSubview(imageArtboardView)

        // need to disable autoresizing mask for self since this view will be inside a scroll view,
        // and as such the superview will not be responsible for disabling its autoresizing mask
        [imageArtboardView, self].disableTranslatesAutoresizingMaskIntoConstraints()

        imageArtboardView.set(image: UIImage(named: "knighted")!)
        imageArtboardView.topAnchor <=> self.topAnchor ++ 100
        imageArtboardView.leadingAnchor <=> self.leadingAnchor ++ 100

        imageArtboardView.trailingAnchor <=> self.trailingAnchor -- 100
        imageArtboardView.bottomAnchor <=> self.bottomAnchor -- 100
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
