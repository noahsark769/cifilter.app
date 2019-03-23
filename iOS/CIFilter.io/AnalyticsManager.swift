//
//  AnalyticsManager.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 3/23/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation
import Mixpanel
import Sentry

final class AnalyticsManager {
    static let shared = AnalyticsManager()

    func track(event: String, properties: Properties? = nil) {
        #if DEBUG
        print("Analytic: \(event) \(properties ?? [:])")
        #else
        Mixpanel.mainInstance().track(event: event, properties: properties)
        NonFatalManager.shared.breadcrumb("analytic_\(event)", data: properties)
        #endif
    }
}
