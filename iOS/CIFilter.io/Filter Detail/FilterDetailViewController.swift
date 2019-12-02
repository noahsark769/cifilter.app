//
//  FilterDetailViewController.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/2/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import Combine
import ColorCompatibility
import SwiftUI

struct NoFilterSelectedView: View {
    var body: some View {
        HStack {
            Image(systemName: "arrow.left")
            Text("Select a CIFilter from the sidebar")
        }
    }
}

final class FilterDetailViewController: UIViewController {
    private var presentWorkshopCancellable: AnyCancellable? = nil
    private var filterView: FilterDetailView = FilterDetailView()
    var filter: FilterInfo! = nil
    var compressedConstraints: [NSLayoutConstraint] = []
    var nonCompressedConstraints: [NSLayoutConstraint] = []
    private let noFilterSelectedView = UIHostingView(rootView: NoFilterSelectedView())
    private lazy var eitherView = EitherView(views: [self.filterView, self.noFilterSelectedView])

    init() {
        super.init(nibName: nil, bundle: nil)

        self.view.addSubview(eitherView)
        self.view.backgroundColor = ColorCompatibility.systemBackground
        eitherView.disableTranslatesAutoresizingMaskIntoConstraints()
        eitherView.topAnchor <=> self.view.topAnchor
        eitherView.bottomAnchor <=> self.view.bottomAnchor

        compressedConstraints = [
            // TODO: set precedence of these operators correctly so we don't need parens
            (eitherView |= self.view) ++ 10,
            (eitherView =| self.view) -- 10
        ]
        nonCompressedConstraints = [
            // Constrain to edges, unless that makes it bigger than 600pt
            eitherView.widthAnchor <=> 600,
            eitherView.centerXAnchor <=> self.view.centerXAnchor
        ]

        self.updateConstraintsForTraitCollection()
        eitherView.setEnabled(noFilterSelectedView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func set(filter: FilterInfo) {
        eitherView.setEnabled(filterView)
        self.title = filter.name
        self.filter = filter
        filterView.set(filter: filter)
        self.presentWorkshopCancellable = filterView.didTapWorkshop.sink { [weak self] _ in
            guard let self = self else { return }
            self.presentFilterWorkshop(filter: filter)
        }
        AnalyticsManager.shared.track(event: "filter_detail", properties: ["name": filter.name])
    }

    func presentFilterWorkshop(filter: FilterInfo) {
        self.presentFilterWorkshopModally(filter: filter)
    }

    func presentFilterWorkshopModally(filter: FilterInfo) {
        let vc = FilterWorkshopViewController(filter: filter)
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.isTranslucent = false
        navigationController.modalPresentationStyle = .fullScreen
        self.splitViewController?.present(navigationController, animated: true, completion: nil)
    }

    private func updateConstraintsForTraitCollection() {
        if self.traitCollection.horizontalSizeClass == .compact {
            nonCompressedConstraints.forEach { $0.isActive = false }
            compressedConstraints.forEach { $0.isActive = true }
        } else {
            nonCompressedConstraints.forEach { $0.isActive = true }
            compressedConstraints.forEach { $0.isActive = false }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.updateConstraintsForTraitCollection()
    }
}

// Hacky stuff as per https://stackoverflow.com/questions/27243158/hiding-the-master-view-controller-with-uisplitviewcontroller-in-ios8
extension UISplitViewController {
    func toggleMasterView() {
        let barButtonItem = self.displayModeButtonItem
        UIApplication.shared.sendAction(barButtonItem.action!, to: barButtonItem.target, from: nil, for: nil)
    }
}
