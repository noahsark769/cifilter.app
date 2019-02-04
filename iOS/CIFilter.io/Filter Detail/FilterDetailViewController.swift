//
//  FilterDetailViewController.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/2/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let isCompressed = UIScreen.main.bounds.width < 415

final class FilterDetailViewController: UIViewController {
    private let bag = DisposeBag()
    private var presentWorkshopSubscription: Disposable? = nil
    private var filterView: FilterDetailView = FilterDetailView(isCompressed: isCompressed)

    init() {
        super.init(nibName: nil, bundle: nil)

        self.view.addSubview(filterView)
        self.view.backgroundColor = .white
        filterView.disableTranslatesAutoresizingMaskIntoConstraints()
        filterView.topAnchor <=> self.view.topAnchor
        filterView.bottomAnchor <=> self.view.bottomAnchor

        // Constrain to edges, unless that makes it bigger than 600pt
        if isCompressed {
            // TODO: set precedence of these operators correctly so we don't need parens
            (filterView |= self.view) ++ 10
            (filterView =| self.view) -- 10
        } else {
            filterView.widthAnchor <=> 600
            filterView.centerXAnchor <=> self.view.centerXAnchor
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func set(filter: FilterInfo) {
        self.title = filter.name
        filterView.set(filter: filter)
        self.presentWorkshopSubscription?.dispose()
        self.presentWorkshopSubscription = filterView.rx.workshopTap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            let vc = FilterWorkshopViewController(filter: filter)
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.navigationBar.isTranslucent = false
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(self.workshopViewControllerSelectedDone)
            )
            self.splitViewController?.present(navigationController, animated: true, completion: nil)
        })
    }

    @objc private func workshopViewControllerSelectedDone(_ sender: Any) {
        self.splitViewController?.dismiss(animated: true, completion: nil)
    }
}

extension FilterDetailViewController: FilterListViewControllerDelegate {
    func filterListViewController(_ vc: FilterListViewController, didTapFilterInfo filter: FilterInfo) {
        self.set(filter: filter)

        // `self.splitViewController` might be nil here if we're in a horizontally compact environment
        // with the filter list VC currently active, but we know the filter list VC's
        // splitViewController will always be non-nil, so we use that
        guard let splitViewController = vc.splitViewController, let navController = self.navigationController else {
            print("WARNING no split view controller!!")
            return
        }
        splitViewController.toggleMasterView()
        splitViewController.showDetailViewController(navController, sender: nil)
    }
}

// Hacky stuff as per https://stackoverflow.com/questions/27243158/hiding-the-master-view-controller-with-uisplitviewcontroller-in-ios8
extension UISplitViewController {
    func toggleMasterView() {
        let barButtonItem = self.displayModeButtonItem
        UIApplication.shared.sendAction(barButtonItem.action!, to: barButtonItem.target, from: nil, for: nil)
    }
}
