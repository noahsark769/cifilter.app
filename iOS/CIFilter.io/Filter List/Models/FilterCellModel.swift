//
//  FilterCellModel.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/29/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import ReactiveLists
import SwiftUI

final class FilterCellModel: TableCellViewModel, DiffableViewModel {
    var registrationInfo = ViewRegistrationInfo(classType: HostingCell<FilterListNameView>.self)
    var accessibilityFormat: CellAccessibilityFormat = "FilterListNameCell"
    let cellIdentifier = "FilterListNameCell"
    let rowHeight: CGFloat = UITableView.automaticDimension
    var didSelect: DidSelectClosure? = nil
    var didSelectJumpToWorkshop: DidSelectClosure? = nil

    let filter: CIFilter

    init(filter: CIFilter, didSelect: @escaping DidSelectClosure, didSelectJumpToWorkshop: @escaping DidSelectClosure) {
        self.filter = filter
        self.didSelect = didSelect
        self.didSelectJumpToWorkshop = didSelectJumpToWorkshop
    }

    func applyViewModelToCell(_ cell: UITableViewCell) {
        guard let cell = cell as? HostingCell<FilterListNameView> else { return }
        cell.rootView = FilterListNameView(name: self.filter.name, description: self.filter.description)
//        cell.set(text: "\(self.filter.name)")
    }

    var diffingKey: String {
        return self.filter.name
    }
}
