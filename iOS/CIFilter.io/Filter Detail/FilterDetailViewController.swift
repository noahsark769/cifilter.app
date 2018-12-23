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

final class FilterDetailViewController: UIViewController {
    private let bag = DisposeBag()
    private var presentWorkshopSubscription: Disposable? = nil
    private let filterView = FilterDetailView()

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
        filterView.set(filter: filter)
        self.presentWorkshopSubscription?.dispose()
        self.presentWorkshopSubscription = filterView.rx.workshopTap.subscribe(onNext: { [weak self] in
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

        // `self.splitViewController` might be nil here if we're in a horizontally compact environment,
        // but we know the filter list VC's splitViewController will always be non-nil
        guard let splitViewController = vc.splitViewController else {
            print("WARNING no split view controller!!")
            return
        }
        splitViewController.showDetailViewController(self, sender: nil)
    }
}
