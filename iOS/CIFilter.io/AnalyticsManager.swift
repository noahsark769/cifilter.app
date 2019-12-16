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

import Mixpanel

final class AnalyticsManager {
    static let shared = AnalyticsManager()

    func initialize() {
        Mixpanel.initialize(token: CIFilterIoKeys().mixpanelToken)
        Mixpanel.mainInstance().registerSuperProperties([
            "uuid": UUIDManager.shared.uuid().uuidString,
            "environment": AppDelegate.shared.environment().analytic,
            "sha": AppDelegate.shared.sha(),
            "commitNumber": AppDelegate.shared.commitNumber(),
            "language": Locale.preferredLanguages.first ?? "unknown",
            "locale": Locale.current.identifier
        ])
    }

    func track(event: String, properties: Properties? = nil) {
        #if DEBUG
        print("Analytic: \(event) \(properties ?? [:])")
        #else
        Mixpanel.mainInstance().track(event: event, properties: properties)
        NonFatalManager.shared.breadcrumb("analytic_\(event)", data: properties)
        #endif
    }
}
