//
//  FilterListViewController.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/9/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import ReactiveLists

private final class FilterCellModel: TableCellViewModel, DiffableViewModel {
    var registrationInfo = ViewRegistrationInfo(classType: UITableViewCell.self)
    var accessibilityFormat: CellAccessibilityFormat = "UITableViewCell"
    let cellIdentifier = "UITableViewCell"

    private let filter: CIFilter

    init(filter: CIFilter) {
        self.filter = filter
    }

    func applyViewModelToCell(_ cell: UITableViewCell) {
        cell.textLabel?.text = "\(self.filter.name)"
    }

    var diffingKey: String {
        return self.filter.name
    }
}

final class FilterListViewController: UITableViewController {
    private let filterNames: [String]
    private var driver: TableViewDriver! = nil
    init() {
        filterNames = CIFilter.filterNames(inCategory: nil)
        super.init(nibName: nil, bundle: nil)
        self.title = "Filters"

        let tableModel = TableViewModel(cellViewModels: filterNames.map { filterName in
            return FilterCellModel(filter: CIFilter(name: filterName)!)
        })
        driver = TableViewDriver(tableView: self.tableView, tableViewModel: tableModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
