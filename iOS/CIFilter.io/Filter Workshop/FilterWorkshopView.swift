//
//  FilterWorkshopView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/10/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

final class FilterWorkshopView: UIView {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageArtboardView = ImageArtboardView(name: "inputImage")
//    private let imageArtboardView2 = ImageArtboardView(name: "outputImage")

    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.addSubview(scrollView)

        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 0.1
        contentView.backgroundColor = UIColor(patternImage: UIImage(named: "workshop-background")!)
        scrollView.delegate = self

        scrollView.edgesToSuperview()
        scrollView.addSubview(contentView)
        contentView.addSubview(imageArtboardView)
//        contentView.addSubview(imageArtboardView2)

        [imageArtboardView, contentView].disableTranslatesAutoresizingMaskIntoConstraints()

        imageArtboardView.set(image: UIImage(named: "knighted")!)
        imageArtboardView.topAnchor <=> contentView.topAnchor ++ 100
        imageArtboardView.leadingAnchor <=> contentView.leadingAnchor ++ 100

        let trailingConstraint = imageArtboardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        trailingConstraint.priority = UILayoutPriority(999)
        trailingConstraint.isActive = true
        trailingConstraint.constant = -100

        let bottomConstraint = imageArtboardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bottomConstraint.priority = UILayoutPriority(999)
        bottomConstraint.isActive = true
        bottomConstraint.constant = -100

        let trailingAtLeastConstraint = imageArtboardView.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor)
        trailingAtLeastConstraint.priority = .required
        trailingAtLeastConstraint.isActive = true
        trailingAtLeastConstraint.constant = -100

        let bottomAtLeastConstraint = imageArtboardView.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor)
        bottomAtLeastConstraint.priority = .required
        bottomAtLeastConstraint.isActive = true
        bottomAtLeastConstraint.constant = -100
//        imageArtboardView.edges(to: contentView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateMinZoomScaleForSize(self.bounds.size)
    }

    private func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / contentView.bounds.width
        let heightScale = size.height / contentView.bounds.height
        let minScale = min(widthScale, heightScale)

//        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
}

extension FilterWorkshopView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
}
