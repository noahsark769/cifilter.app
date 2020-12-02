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
import SwiftUI
import Combine

enum AppEnvironment: String {
    case release = "release"
    case debug = "debug"

    var analytic: String {
        return self.rawValue
    }
}

class SceneDelegate: NSObject, UISceneDelegate {
    var window: UIWindow?
    var cancellables = Set<AnyCancellable>()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = scene as? UIWindowScene else {
            return
        }

        let filterNames = CIFilter.filterNames(inCategory: nil)
        let data: [FilterInfo] = filterNames.compactMap { filterName in
            let filter = CIFilter(name: filterName)!
            let filterInfo = try! FilterInfo(filter: filter)
            return filterInfo
        }.sorted { lhs, rhs in
            return lhs.name < rhs.name
        }
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .sortedKeys
//        print(String(data: try! encoder.encode(data), encoding: .utf8)!)

        window = UIWindow(windowScene: scene)
        let splitViewController = UISplitViewController()
        let filterListViewController = FilterListViewController(filterInfos: data)
        let navController = UINavigationController(rootViewController: filterListViewController)
        navController.navigationBar.prefersLargeTitles = true

        let detailViewController = FilterDetailViewController()
        let detailNavController = UINavigationController(rootViewController: detailViewController)
        splitViewController.viewControllers = [navController, detailNavController]
        filterListViewController.didTapFilterInfo.sink { info in
            detailViewController.rootView = FilterDetailSwiftUIView(
                filterInfo: info,
                didTapTryIt: { [weak splitViewController] in
                    guard let splitViewController = splitViewController else { return }
                    let vc = FilterWorkshopViewController(filter: info)
                    let navigationController = FilterWorkshopNavigationController(rootViewController: vc)
                    splitViewController.present(navigationController, animated: true, completion: nil)
                },
                didTapShare: {
                    detailViewController.presentShareSheet(filterInfo: info)
                }
            )
            splitViewController.toggleMasterView()
            splitViewController.showDetailViewController(detailNavController, sender: nil)
        }.store(in: &self.cancellables)

        splitViewController.delegate = self

        window?.rootViewController = splitViewController
        window?.makeKeyAndVisible()
        splitViewController.toggleMasterView()
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
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

        AnalyticsManager.shared.initialize()

        BuiltInImageManager.shared.loadImages()

        return true
    }

    func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    lazy var buildInformation: BuildInformation = {
        guard let url = Bundle.main.url(forResource: "buildInformation", withExtension: "json") else {
            fatalError("Build information could not be determined")
        }
        let decoder = JSONDecoder()
        guard let info = try? decoder.decode(BuildInformation.self, from: Data(contentsOf: url)) else {
            fatalError("Build information could not be decoded")
        }
        return info
    }()

    func sha() -> String {
        return buildInformation.gitSha
    }

    func commitNumber() -> String {
        return buildInformation.numberOfCommits
    }

    func environment() -> AppEnvironment {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }
}

extension SceneDelegate: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

struct BuildInformation: Codable {
    let gitSha: String
    let numberOfCommits: String
}

