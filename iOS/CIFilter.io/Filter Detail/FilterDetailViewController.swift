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
    init(splitViewController: UISplitViewController) {
        super.init(rootView: FilterDetailSwiftUIView(filterInfo: nil, didTapTryIt: { }, didTapShare: { }))
        self.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.largeTitleDisplayMode = .never
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
