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

final class FilterWorkshopView: UIView {
    private var hasInitiallyLaidOut: Bool = false
    private let scrollView = UIScrollView()
    private let applicator = AsyncFilterApplicator()
    private let bag = DisposeBag()
    private lazy var contentView: FilterWorkshopContentView = {
        return FilterWorkshopContentView(applicator: self.applicator)
    }()
    private let consoleView = ImageWorkshopConsoleView()

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

        consoleView.disableTranslatesAutoresizingMaskIntoConstraints()
        addSubview(consoleView)
        consoleView.leadingAnchor <=> self.leadingAnchor ++ 20
        consoleView.topAnchor <=> self.topAnchor ++ 20

        applicator.events.observeOn(MainScheduler.instance).subscribe(onNext: { event in
            switch event {
            case .generationStarted:
                self.consoleView.update(for: .showActivity)
            case let .generationCompleted(_, totalTime):
                self.consoleView.update(for: .hideActivity)

                // Only show a success message if the generation took more than 4 seconds, so as
                // not to be intrusive for filters that don't take much time to apply
                if totalTime > 4 {
                    self.consoleView.update(for: .success(message: "Generation completed in \(String(format: "%.2f", totalTime)) seconds", animated: true))
                }
            case .generationErrored:
                self.consoleView.update(for: .hideActivity)
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
