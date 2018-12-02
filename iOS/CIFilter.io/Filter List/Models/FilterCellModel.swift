//
//  FilterCellModel.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/29/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import ReactiveLists

final class FilterCellModel: TableCellViewModel, DiffableViewModel {
    var registrationInfo = ViewRegistrationInfo(classType: FilterListNameCell.self)
    var accessibilityFormat: CellAccessibilityFormat = "FilterListNameCell"
    let cellIdentifier = "FilterListNameCell"
    let rowHeight: CGFloat = UITableView.automaticDimension
    var didSelect: DidSelectClosure? = nil

    private let filter: CIFilter

    init(filter: CIFilter, didSelect: @escaping () -> Void) {
        self.filter = filter
        self.didSelect = didSelect
    }

    func applyViewModelToCell(_ cell: UITableViewCell) {
        guard let cell = cell as? FilterListNameCell else { return }
        cell.set(text: "\(self.filter.name)")
    }

    var diffingKey: String {
        return self.filter.name
    }
}
