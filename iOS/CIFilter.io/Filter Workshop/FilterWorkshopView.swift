//
//  FilterWorkshopView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/10/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 * Small view that indicates that the application of a filter is in progress.
 */
final class FilterApplicationIndicator: UIView {
    private let activityIndicator = UIActivityIndicatorView(style: .white)
    init() {
        super.init(frame: .zero)
        self.backgroundColor = Colors.primary.color
        addSubview(activityIndicator)
        activityIndicator.edges(to: self, insets: UIEdgeInsets(all: 10))
        self.layer.borderColor = UIColor(rgb: 0xEFEFEF).cgColor
        self.layer.borderWidth = 1 / UIScreen.main.scale
        self.layer.cornerRadius = 2
        self.layer.shadowColor = Colors.borderGray.color.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 3
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        activityIndicator.startAnimating()
    }

    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}

final class FilterWorkshopView: UIView {
    private var hasInitiallyLaidOut: Bool = false
    private let scrollView = UIScrollView()
    private let applicator = AsyncFilterApplicator()
    private let bag = DisposeBag()
    private lazy var contentView: FilterWorkshopContentView = {
        return FilterWorkshopContentView(applicator: self.applicator)
    }()
    private let applicationIndicator = FilterApplicationIndicator()

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

        applicationIndicator.disableTranslatesAutoresizingMaskIntoConstraints()
        addSubview(applicationIndicator)
        applicationIndicator.leadingAnchor <=> self.leadingAnchor ++ 20
        applicationIndicator.topAnchor <=> self.topAnchor ++ 20
        applicationIndicator.isHidden = true

        applicator.events.observeOn(MainScheduler.instance).subscribe(onNext: { event in
            switch event {
            case .generationStarted:
                self.applicationIndicator.isHidden = false
                self.applicationIndicator.startAnimating()
            case .generationCompleted, .generationErrored:
                self.applicationIndicator.isHidden = true
                self.applicationIndicator.stopAnimating()
            }
        }).disposed(by: bag)
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
