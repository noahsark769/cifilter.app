//
//  FilterListViewController.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/9/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import ReactiveLists
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

    // pecker:ignore (https://github.com/woshiccm/Pecker/issues/27)
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in

            return self.configurator?.makeContextMenu(indexPath: indexPath)
        })
    }
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
    private var driver: FilterListViewControllerTableViewDriver! = nil
    private var cancellables = Set<AnyCancellable>()
    private let searchSubject = PassthroughSubject<String?, Never>()

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
                diffingKey: "filter-section-key-\(key)",
                cellViewModels: filters.map { filter in
                    return FilterCellModel(
                        filter: CIFilter(name: filter.name)!,
                        didSelect: { [weak self] in
                            guard let `self` = self else { return }
                            self.navigationItem.searchController?.searchBar.resignFirstResponder()
                            self.didTapFilterInfo.send(filter)
                        },
                        didSelectJumpToWorkshop: { [weak self] in
                            guard let `self` = self else { return }
                            let vc = FilterWorkshopViewController(filter: filter)
                            let navigationController = FilterWorkshopNavigationController(rootViewController: vc)
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
            tableView: self.tableView
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(didTapSettings))

        self.configureNavigationBarForCloseButton()
        NotificationCenter.default.addObserver(forName: UIScene.willConnectNotification, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.configureNavigationBarForCloseButton()
        }

        NotificationCenter.default.addObserver(forName: UIScene.didDisconnectNotification, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.configureNavigationBarForCloseButton()
        }

        searchSubject.debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { $0 ?? "" }
            .removeDuplicates()
            .sink { [weak self] text in
                guard let `self` = self else { return }
                self.driver.tableViewModel = self.generateTableModel(searchText: text)
            }.store(in: &self.cancellables)
        searchSubject.send(nil) // populate initial list
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    @objc private func workshopViewControllerSelectedDone(_ sender: Any) {
        self.splitViewController?.dismiss(animated: true, completion: nil)
    }

    @objc private func didTapSettings() {
        let view = SettingsView()
        view.didTapDone.sink(receiveValue: {
            self.dismiss(animated: true, completion: nil)
        }).store(in: &cancellables)
        let controller = UIHostingController(rootView: view)
        self.present(controller, animated: true, completion: nil)
    }

    @objc private func didTapClose() {
        let controller = UIAlertController(title: "", message: "Close this window?", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        controller.addAction(UIAlertAction(title: "Close", style: .destructive, handler: { _ in
            guard let session = self.view.window?.windowScene?.session else {
                return
            }
            UIApplication.shared.requestSceneSessionDestruction(session, options: nil, errorHandler: nil)
        }))
        self.present(controller, animated: true, completion: nil)
    }

    private func configureNavigationBarForCloseButton() {
        if UIApplication.shared.connectedScenes.count > 1 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(didTapClose))
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
}

extension FilterListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchSubject.send(searchController.searchBar.text)
    }
}
