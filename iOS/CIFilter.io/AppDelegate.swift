//
//  AppDelegate.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/9/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true

        let filterNames = CIFilter.filterNames(inCategory: nil)
        let data: [FilterInfo] = filterNames.compactMap { filterName in
            let filter = CIFilter(name: filterName)!
            return try? FilterInfo(filter: filter)
        }
//        print(String(data: try! JSONEncoder().encode(data), encoding: .utf8)!)

        window = UIWindow()
        let splitViewController = UISplitViewController()
        let filterListViewController = FilterListViewController(filterInfos: data)
        let navController = UINavigationController(rootViewController: filterListViewController)
        navController.navigationBar.prefersLargeTitles = true
        let filterDetailViewController = FilterDetailViewController()
        filterListViewController.delegate = filterDetailViewController
        splitViewController.viewControllers = [navController, filterDetailViewController]
        window?.rootViewController = splitViewController
        window?.makeKeyAndVisible()
        return true
    }
}

