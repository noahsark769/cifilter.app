//
//  NonFatalManager.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 3/23/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation
import Sentry
#if !targetEnvironment(macCatalyst)
import Mixpanel
#endif

final class NonFatalManager {
    static let shared = NonFatalManager()

    #if !targetEnvironment(macCatalyst)
    func log(_ identifier: String, data: Properties = [:]) {
        print("WARNING!! \(identifier)")
        var mixpanelData = data
        mixpanelData["identifier"] = identifier
        AnalyticsManager.shared.track(event: "nonfatal", properties: mixpanelData)

        let sentry = Client.shared!
        sentry.snapshotStacktrace {
            let event = Event(level: .error)
            event.message = identifier
            event.extra = data
            sentry.appendStacktrace(to: event)
            sentry.send(event: event)
        }
    }
    #else
    func log(_ identifier: String, data: [String: Any] = [:]) {
        print("WARNING!! \(identifier)")

        let sentry = Client.shared!
        sentry.snapshotStacktrace {
            let event = Event(level: .error)
            event.message = identifier
            event.extra = data
            sentry.appendStacktrace(to: event)
            sentry.send(event: event)
        }
    }
    #endif

    func breadcrumb(_ category: String, data: [String: Any]? = nil) {
        let sentry = Client.shared!
        print("Breadcrumb: \(category)")
        let breadcrumb = Breadcrumb(level: .info, category: category)
        if let data = data {
            breadcrumb.data = data
        }
        sentry.breadcrumbs.add(breadcrumb)
    }
}
