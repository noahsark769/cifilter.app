//
//  FilterListViewController.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/9/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import ReactiveLists

private final class FilterHeaderModel: TableSectionHeaderFooterViewModel {
    let title: String?
    let height: CGFloat? = UITableView.automaticDimension
    let viewInfo: SupplementaryViewInfo?

    init(filterName: String) {
        title = filterName
        viewInfo = SupplementaryViewInfo(
            registrationInfo: ViewRegistrationInfo(classType: FilterCategoryHeaderView.self),
            kind: .header,
            accessibilityFormat: "FilterCategoryHeaderView"
        )
    }

    func applyViewModelToView(_ view: UIView) {
        (view as? FilterCategoryHeaderView)?.label.text = title
    }
}

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

    private func generateTableModel(searchText: String?) -> TableViewModel {
        let filteredNames = filterNames.filter {
            guard let text = searchText else { return true }
            guard text.count > 0 else { return true }
            return $0.lowercased().contains(text.lowercased())
        }
        return TableViewModel(sectionModels: [
            TableSectionViewModel(
                cellViewModels: filteredNames.map { filterName in
                    return FilterCellModel(filter: CIFilter(name: filterName)!)
                },
                headerViewModel: FilterHeaderModel(filterName: filteredNames[0])
            )
        ])
//        return TableViewModel(cellViewModels: filteredNames.map { filterName in
//            return FilterCellModel(filter: CIFilter(name: filterName)!)
//        })
    }

    init() {
        filterNames = CIFilter.filterNames(inCategory: nil)
        super.init(nibName: nil, bundle: nil)
        self.title = "Filters"
        self.definesPresentationContext = true

        driver = TableViewDriver(
            tableView: self.tableView,
            tableViewModel: generateTableModel(searchText: nil)
        )

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FilterListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        driver.tableViewModel = generateTableModel(searchText: searchController.searchBar.text)
    }
}
