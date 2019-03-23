//
//  NonFatalManager.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 3/23/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation
import Sentry
import Mixpanel

final class NonFatalManager {
    static let shared = NonFatalManager()

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

    func breadcrumb(_ category: String, data: Properties? = nil) {
        let sentry = Client.shared!
        print("Breadcrumb: \(category)")
        let breadcrumb = Breadcrumb(level: .info, category: category)
        if let data = data {
            breadcrumb.data = data
        }
        sentry.breadcrumbs.add(breadcrumb)
    }
}
