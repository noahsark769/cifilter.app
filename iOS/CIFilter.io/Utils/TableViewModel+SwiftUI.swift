//
//  TableViewModel+SwiftUI.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 7/1/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import Foundation
import ReactiveLists
import SwiftUI

extension TableCellViewModel where Self: View {
    var registrationInfo: ViewRegistrationInfo {
        return ViewRegistrationInfo(classType: HostingCell<Self>.self)
    }

    var cellIdentifier: String {
        return String(describing: HostingCell<Self>.self)
    }

    var rowHeight: CGFloat? {
        return UITableView.automaticDimension
    }

    func applyViewModelToCell(_ cell: UITableViewCell) {
        guard let cell = cell as? HostingCell<Self> else {
            return
        }
        cell.rootView = self
    }
}
