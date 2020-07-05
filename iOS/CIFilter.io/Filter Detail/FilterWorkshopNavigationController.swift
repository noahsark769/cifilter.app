//
//  FilterDetailViewController.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/2/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import Combine
import SwiftUI

struct NoFilterSelectedView: View {
    var body: some View {
        HStack {
            Image(systemName: "arrow.left")
            Text("Select a CIFilter from the sidebar")
        }
    }
}

final class FilterWorkshopNavigationController: UINavigationController {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        self.navigationBar.isTranslucent = false
        self.modalPresentationStyle = .fullScreen
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Hacky stuff as per https://stackoverflow.com/questions/27243158/hiding-the-master-view-controller-with-uisplitviewcontroller-in-ios8
extension UISplitViewController {
    func toggleMasterView() {
        let barButtonItem = self.displayModeButtonItem
        UIApplication.shared.sendAction(barButtonItem.action!, to: barButtonItem.target, from: nil, for: nil)
    }
}
