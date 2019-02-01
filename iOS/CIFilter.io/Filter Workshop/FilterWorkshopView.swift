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
    // TODO: this is a VERY ugly hack
    static var globalPanGestureRecognizer: UIPanGestureRecognizer!
    private var needsZoomScaleUpdate: Bool = false
    private let scrollView = UIScrollView()
    private let applicator: AsyncFilterApplicator
    private let bag = DisposeBag()
    private lazy var contentView: FilterWorkshopContentView = {
        return FilterWorkshopContentView(applicator: self.applicator)
    }()
    private let consoleView = ImageWorkshopConsoleView()

    init(applicator: AsyncFilterApplicator) {
        self.applicator = applicator
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.addSubview(scrollView)
        // TODO: Add double-tap gestures for zooming to this scroll view

        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 0.1
        scrollView.delegate = self

        scrollView.edgesToSuperview()
        scrollView.addSubview(contentView)
        // scroll view content size constraint:
        contentView.edgesToSuperview()

        consoleView.disableTranslatesAutoresizingMaskIntoConstraints()
        addSubview(consoleView)
        consoleView.leadingAnchor <=> self.leadingAnchor ++ 20
        consoleView.topAnchor <=> self.topAnchor ++ 20

        FilterWorkshopView.globalPanGestureRecognizer = scrollView.panGestureRecognizer

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
            case let .generationErrored(error):
                self.consoleView.update(for: .hideActivity)

                if case .needsMoreParameters = error {
                    return
                }

//                guard case error != AsyncFilterApplicator.Error.needsMoreParameters else { return }
                self.consoleView.update(for: .error(message: "Generation errored. Please submit an issue on github. Error: \(error)", animated: true))
            }
        }).disposed(by: bag)

        needsZoomScaleUpdate = true // we need to update the zoom scale on first layout
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.layoutIfNeeded()

        let widthScale = scrollView.bounds.width / contentView.bounds.width
        let heightScale = scrollView.bounds.height / contentView.bounds.height
        let minScale = min(widthScale, heightScale)

        if !minScale.isInfinite {
            scrollView.minimumZoomScale = minScale
        }

        if needsZoomScaleUpdate && !minScale.isInfinite {
            scrollView.zoomScale = minScale
            needsZoomScaleUpdate = false
        }
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
