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

class AbstractContextMenuTableViewConfigurator {
    @available(iOS 13.0, *)
    func makeContextMenu(indexPath: IndexPath) -> UIMenu {
        fatalError()
    }
}

@available(iOS 13.0, *)
final class FilterListViewControllerContextMenuConfigurator: AbstractContextMenuTableViewConfigurator {
    weak var driver: TableViewDriver?

    override func makeContextMenu(indexPath: IndexPath) -> UIMenu {
        guard let tableViewModel = driver?.tableViewModel, let cellViewModel = tableViewModel[ifExists: indexPath] else {
            fatalError("Table View Model has an invalid configuration!")
        }

        guard let model = cellViewModel as? FilterCellModel else {
            fatalError("Expected filter cell model")
        }

        let exampleProvider = FilterExampleProvider()

        let viewDetails = UIAction(title: "View details", image: UIImage(systemName: "arrow.right.circle.fill")) { action in
            model.didSelect?()
        }

        var actions = [viewDetails]
        if exampleProvider.state(forFilterName: model.filter.name).isAvailable {
            let apply = UIAction(title: "Apply to image", image: UIImage(systemName: "square.and.pencil")) { action in
                model.didSelectJumpToWorkshop?()
            }
            actions.append(apply)
        }

        // Create our menu with both the edit menu and the share action
        return UIMenu(title: model.filter.name, children: actions)
    }
}

final class FilterListViewControllerTableViewDriver: TableViewDriver {
    var configurator: AbstractContextMenuTableViewConfigurator?

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in

            return self.configurator?.makeContextMenu(indexPath: indexPath)
        })
    }
}

protocol FilterListViewControllerDelegate: class {
    func filterListViewController(_ vc: FilterListViewController, didTapFilterInfo: FilterInfo)
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

    weak var delegate: FilterListViewControllerDelegate?
    private let filterInfos: [FilterInfo]
    private var driver: FilterListViewControllerTableViewDriver! = nil
    private let bag = DisposeBag()
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
                            self.delegate?.filterListViewController(self, didTapFilterInfo: filter)
                        },
                        didSelectJumpToWorkshop: { [weak self] in
                            guard let `self` = self else { return }
                            let vc = FilterWorkshopViewController(filter: filter)
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.navigationBar.isTranslucent = false
                            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
                                barButtonSystemItem: .done,
                                target: self,
                                action: #selector(self.workshopViewControllerSelectedDone)
                            )
                            navigationController.modalPresentationStyle = .fullScreen
                            self.splitViewController?.present(navigationController, animated: true, completion: nil)
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

        driver = FilterListViewControllerTableViewDriver(
            tableView: self.tableView,
            tableViewModel: generateTableModel(searchText: nil)
        )
        if #available(iOS 13, *) {
            let configurator = FilterListViewControllerContextMenuConfigurator()
            driver.configurator = configurator
            configurator.driver = driver
        }

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController

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

    @objc private func workshopViewControllerSelectedDone(_ sender: Any) {
        self.splitViewController?.dismiss(animated: true, completion: nil)
    }
}

extension FilterListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchSubject.onNext(searchController.searchBar.text)
    }
}
