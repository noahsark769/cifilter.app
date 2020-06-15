//
//  UserDefaultsConfig.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 8/4/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation
import Combine

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

final class UserDefaultsConfig: ObservableObject {
    static let shared = UserDefaultsConfig()
    let objectWillChange = PassthroughSubject<Void, Never>()

    // No user defaults here at this time
    @UserDefault("com.noahgilmore.cifiltio.enableSwiftUI", defaultValue: false)
    var enableSwiftUIFilterDetail: Bool {
        willSet {
            objectWillChange.send()
        }
    }
}
