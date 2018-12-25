//
//  FilterWorkshopView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/10/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

final class FilterWorkshopView: UIView {
    private var hasInitiallyLaidOut: Bool = false
    private let scrollView = UIScrollView()
    private let contentView = FilterWorkshopContentView()

    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.addSubview(scrollView)
        // TODO: Add double-tap gestures for zooming to this scroll view

        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 0.1
        scrollView.delegate = self

        scrollView.edgesToSuperview()
        scrollView.addSubview(contentView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        if !hasInitiallyLaidOut {
            updateMinZoomScaleForSize(self.bounds.size)
            hasInitiallyLaidOut = true
        }
    }

    private func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / contentView.bounds.width
        let heightScale = size.height / contentView.bounds.height
        let minScale = min(widthScale, heightScale)

        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }

    func set(filter: FilterInfo) {
        contentView.set(filter: filter)
    }
}

extension FilterWorkshopView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
}
