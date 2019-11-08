//
//  FilterDetailViewController.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/2/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import Combine
import ColorCompatibility

private let isCompressed = UIScreen.main.bounds.width < 415

final class FilterDetailViewController: UIViewController {
    private var presentWorkshopCancellable: AnyCancellable? = nil
    private var filterView: FilterDetailView = FilterDetailView(isCompressed: isCompressed)
    var filter: FilterInfo! = nil

    init() {
        super.init(nibName: nil, bundle: nil)

        self.view.addSubview(filterView)
        self.view.backgroundColor = ColorCompatibility.systemBackground
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

        let interaction = UIContextMenuInteraction(delegate: self)
        filterView.addInteraction(interaction)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func set(filter: FilterInfo) {
        self.title = filter.name
        self.filter = filter
        filterView.set(filter: filter)
        self.presentWorkshopCancellable = filterView.didTapWorkshop.sink { [weak self] _ in
            guard let self = self else { return }
            self.presentFilterWorkshop(filter: filter)
        }
        AnalyticsManager.shared.track(event: "filter_detail", properties: ["name": filter.name])
    }

    @objc private func workshopViewControllerSelectedDone(_ sender: Any) {
        self.splitViewController?.dismiss(animated: true, completion: nil)
    }

    func presentFilterWorkshop(filter: FilterInfo) {
        #if targetEnvironment(macCatalyst)
        self.presentFilterWorkshopInScene(filter: filter)
        #else
        self.presentFilterWorkshopModally(filter: filter)
        #endif
    }

    func presentFilterWorkshopModally(filter: FilterInfo) {
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

    func presentFilterWorkshopInScene(filter: FilterInfo) {
        let userActivity = NSUserActivity(activityType: "com.noahgilmore.cifilterio.workshop")
        userActivity.title = filter.name
        userActivity.userInfo = ["filterName": filter.name]
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: userActivity, options: nil, errorHandler: nil)
    }
}

// Hacky stuff as per https://stackoverflow.com/questions/27243158/hiding-the-master-view-controller-with-uisplitviewcontroller-in-ios8
extension UISplitViewController {
    func toggleMasterView() {
        let barButtonItem = self.displayModeButtonItem
        UIApplication.shared.sendAction(barButtonItem.action!, to: barButtonItem.target, from: nil, for: nil)
    }
}

extension FilterDetailViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return UIMenu(title: "", image: nil, identifier: nil, children: [
                UIAction(title: "Open in new window", image: UIImage(systemName: "square.and.arrow.up"), identifier: UIAction.Identifier(rawValue: "open"), handler: { action in
                    self.presentFilterWorkshopInScene(filter: self.filter)
                })
            ])
        })
    }
}
