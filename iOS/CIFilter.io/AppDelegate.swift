//
//  AppDelegate.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/9/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Keys
import Sentry
import Mixpanel

enum Environment: String {
    case release = "release"
    case debug = "debug"

    var analytic: String {
        return self.rawValue
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true

        // Create a Sentry client and start crash handler
        do {
            Client.shared = try Client(dsn: CIFilterIoKeys().sENTRY_DSN)
            try Client.shared?.startCrashHandler()
            Client.shared?.tags = [
                "appVersion": self.appVersion().description,
                "uuid": UUIDManager.shared.uuid().uuidString,
                "environment": self.environment().analytic,
                "sha": self.sha(),
                "commitNumber": self.commitNumber(),
                "language": Locale.preferredLanguages.first ?? "unknown",
                "locale": Locale.current.identifier
            ]
            Client.shared?.enableAutomaticBreadcrumbTracking()
        } catch let error {
            print("SENTRY ERROR: \(error)")
            // Wrong DSN or KSCrash not installed
        }

        Mixpanel.initialize(token: CIFilterIoKeys().mixpanelToken)
        Mixpanel.mainInstance().registerSuperProperties([
            "uuid": UUIDManager.shared.uuid().uuidString,
            "environment": self.environment().analytic,
            "sha": self.sha(),
            "commitNumber": self.commitNumber(),
            "language": Locale.preferredLanguages.first ?? "unknown",
            "locale": Locale.current.identifier
        ])

        let filterNames = CIFilter.filterNames(inCategory: nil)
        let data: [FilterInfo] = filterNames.compactMap { filterName in
            let filter = CIFilter(name: filterName)!
            let filterInfo = try! FilterInfo(filter: filter)
            return filterInfo
        }
//        print(String(data: try! JSONEncoder().encode(data), encoding: .utf8)!)

        window = UIWindow()
        let splitViewController = UISplitViewController()
        let filterListViewController = FilterListViewController(filterInfos: data)
        let navController = UINavigationController(rootViewController: filterListViewController)
        navController.navigationBar.prefersLargeTitles = true
        let filterDetailViewController = FilterDetailViewController()
        filterListViewController.delegate = filterDetailViewController
        filterDetailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        filterDetailViewController.navigationItem.leftItemsSupplementBackButton = true
        filterDetailViewController.navigationItem.largeTitleDisplayMode = .never
        let detailNavController = UINavigationController(rootViewController: filterDetailViewController)
        splitViewController.viewControllers = [navController, detailNavController]
        splitViewController.delegate = self

        window?.rootViewController = splitViewController
        window?.makeKeyAndVisible()

        // preload built in images
        DispatchQueue.global(qos: .default).async {
            print("\(BuiltInImage.all)")
        }

        splitViewController.toggleMasterView()
        return true
    }

    func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    func sha() -> String {
        guard let sha = Bundle.main.object(forInfoDictionaryKey: "NGGitSha") as? String else {
            NonFatalManager.shared.log("GitShaCouldNotBeDetermined")
            return "unknown"
        }
        return sha
    }

    func commitNumber() -> String {
        guard let number = Bundle.main.object(forInfoDictionaryKey: "NGCommitNumber") as? String else {
            NonFatalManager.shared.log("CommitNumberCouldNotBeDetermined")
            return "unknown"
        }
        return number
    }

    func environment() -> Environment {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }
}

extension AppDelegate: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

