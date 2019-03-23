//
//  UUIDManager.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 3/23/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation

final class UUIDManager {
    private static let uuidKey = "com.noahgilmore.trest-ios.uuid"
    static let shared = UUIDManager()

    func uuid() -> UUID {
        if let uuid = UserDefaults.standard.string(forKey: UUIDManager.uuidKey) {
            return UUID(uuidString: uuid)!
        }
        let uuid = UUID()
        UserDefaults.standard.set(uuid.uuidString, forKey: UUIDManager.uuidKey)
        return uuid
    }
}
