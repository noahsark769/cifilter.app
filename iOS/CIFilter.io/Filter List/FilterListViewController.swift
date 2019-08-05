//
//  FilterListViewController.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/9/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import ReactiveLists
import RxSwift
import RxCocoa
import Combine
import SwiftUI

func group(filters: [FilterInfo], into categories: [String]) -> [String: [FilterInfo]] {
    var result: [String: [FilterInfo]] = [:]

    // to make sure the keys are sorted the same was as the passed in categories
    for category in categories {
        result[category] = []
    }
    for filter in filters {
        var found = false
        for category in categories {
            if Set(filter.categories).contains(category) {
                result[category, default: []].append(filter)
                found = true
                break
            }
        }
        if !found {
            result["Other", default: []].append(filter)
        }
    }
    return result
}

final class FilterListViewController: UITableViewController {
    static let categoryNames: [String] = [
        "CICategoryBlur",
        "CICategoryColorAdjustment",
        "CICategoryColorEffect",
        "CICategoryCompositeOperation",
        "CICategoryDistortionEffect",
        "CICategoryGenerator",
        "CICategoryGeometryAdjustment",
        "CICategoryGradient",
        "CICategoryHalftoneEffect",
        "CICategoryReduction",
        "CICategorySharpen",
        "CICategoryStylize",
        "CICategoryTileEffect",
        "CICategoryTransition",
        "Other"
    ]

    let didTapFilterInfo = PassthroughSubject<FilterInfo, Never>()
    private let filterInfos: [FilterInfo]
    private var driver: TableViewDriver! = nil
    private let bag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()
    private let searchSubject = PublishSubject<String?>()

    private func generateTableModel(searchText: String?) -> TableViewModel {
        let filteredFilters = filterInfos.filter {
            guard let text = searchText else { return true }
            guard text.count > 0 else { return true }
            return $0.name.lowercased().contains(text.lowercased())
        }

        let groupedFilters = group(filters: filteredFilters, into: FilterListViewController.categoryNames)

        return TableViewModel(sectionModels: FilterListViewController.categoryNames.compactMap { key in
            guard let filters = groupedFilters[key] else { return nil }
            guard filters.count > 0 else { return nil }
            return TableSectionViewModel(
                cellViewModels: filters.map { filter in
                    return FilterCellModel(
                        filter: CIFilter(name: filter.name)!,
                        didSelect: { [weak self] in
                            guard let `self` = self else { return }
                            self.navigationItem.searchController?.searchBar.resignFirstResponder()
                            self.didTapFilterInfo.send(filter)
                        }
                    )
                },
                headerViewModel: FilterHeaderModel(filterName: key)
            )
        })
    }

    init(filterInfos: [FilterInfo]) {
        self.filterInfos = filterInfos
        super.init(nibName: nil, bundle: nil)
        self.title = "Filters"
        self.definesPresentationContext = true
        self.tableView.separatorStyle = .none

        driver = TableViewDriver(
            tableView: self.tableView,
            tableViewModel: generateTableModel(searchText: nil)
        )

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(didTapSettings))

        searchSubject.throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { $0 ?? "" }
            .subscribe(onNext: { [weak self] text in
                guard let `self` = self else { return }
                self.driver.tableViewModel = self.generateTableModel(searchText: text)
            }).disposed(by: self.bag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTapSettings() {
        let view = SettingsView()
        view.didTapDone.sink(receiveValue: {
            self.dismiss(animated: true, completion: nil)
        }).store(in: &cancellables)
        let controller = UIHostingController(rootView: view)
        self.present(controller, animated: true, completion: nil)
    }
}

extension FilterListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchSubject.onNext(searchController.searchBar.text)
    }
}
