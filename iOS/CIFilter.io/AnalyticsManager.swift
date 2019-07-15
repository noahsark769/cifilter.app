//
//  AnalyticsManager.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 3/23/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation
import Sentry
import Keys

// TODO(UIKitForMac): Mixpanel is commented out, we need to figure out a way to include it

#if !targetEnvironment(UIKitForMac)
import Mixpanel
#endif

final class AnalyticsManager {
    static let shared = AnalyticsManager()

    func initialize() {
        #if os(macOS)
        print("I'm running on Mac")
        #else
        print("I'm NOT running on Mac")
        #endif
        #if !targetEnvironment(UIKitForMac)
//            Mixpanel.initialize(token: CIFilterIoKeys().mixpanelToken)
//            Mixpanel.mainInstance().registerSuperProperties([
//                "uuid": UUIDManager.shared.uuid().uuidString,
//                "environment": AppDelegate.shared.environment().analytic,
//                "sha": AppDelegate.shared.sha(),
//                "commitNumber": AppDelegate.shared.commitNumber(),
//                "language": Locale.preferredLanguages.first ?? "unknown",
//                "locale": Locale.current.identifier
//            ])
        #endif
    }

    #if !targetEnvironment(UIKitForMac)
    func track(event: String, properties: [String: Any]? = nil) {
//    func track(event: String, properties: Properties? = nil) {
        #if DEBUG
        print("Analytic: \(event) \(properties ?? [:])")
        #else
//        Mixpanel.mainInstance().track(event: event, properties: properties)
        NonFatalManager.shared.breadcrumb("analytic_\(event)", data: properties)
        #endif
    }
    #else
    func track(event: String, properties: [String: Any]? = nil) {
        #if DEBUG
        print("Analytic: \(event) \(properties ?? [:])")
        #else
        NonFatalManager.shared.breadcrumb("analytic_\(event)", data: properties)
        #endif
    }
    #endif
}
