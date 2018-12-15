//
//  FilterDetailViewController.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/2/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

final class FilterDetailViewController: UIViewController {
    private let filterView = FilterDetailView()
    private var presentedWorkshopViewController: FilterWorkshopViewController? = nil

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(filterView)
        self.view.backgroundColor = .white
        filterView.disableTranslatesAutoresizingMaskIntoConstraints()
        filterView.topAnchor <=> self.view.topAnchor
        filterView.bottomAnchor <=> self.view.bottomAnchor
        filterView.widthAnchor <=> 600
        filterView.centerXAnchor <=> self.view.centerXAnchor
    }

    func set(filter: FilterInfo) {
        filterView.set(filter: filter, tryHandler: { [weak self] in
            guard let `self` = self else { return }
            let vc = FilterWorkshopViewController(filter: filter)
            let navigationController = UINavigationController(rootViewController: vc)
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
    }
}
