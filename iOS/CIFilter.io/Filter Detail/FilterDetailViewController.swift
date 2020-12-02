//
//  FilterDetailViewController.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 7/5/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import Foundation
import SwiftUI

final class FilterDetailViewController: UIHostingController<FilterDetailSwiftUIView> {
    private var hasAutoShownPrimaryView = false

    init() {
        super.init(rootView: FilterDetailSwiftUIView(filterInfo: nil, didTapTryIt: { }, didTapShare: { }))
        self.navigationItem.largeTitleDisplayMode = .never
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // If we're first being displayed, auto-toggle the primary view controller. This means that
        // the sidebar will auto-show in iPad portrait orientation
        if !self.hasAutoShownPrimaryView {
            self.splitViewController?.toggleMasterView()
            self.hasAutoShownPrimaryView = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        self.navigationItem.leftItemsSupplementBackButton = true

        super.viewDidAppear(animated)
    }

    func presentShareSheet(filterInfo: FilterInfo) {
        let controller = UIActivityViewController(activityItems: [
            URL(string: "https://cifilter.io/\(filterInfo.name)")!
        ], applicationActivities: nil)

        if self.traitCollection.userInterfaceIdiom == .pad {
            controller.modalPresentationStyle = .popover
            controller.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        }

        self.present(controller, animated: true, completion: nil)
    }
}
