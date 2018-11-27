//
//  Dictionary+Validation.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/27/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import Foundation

extension Dictionary {
    enum ValidationError<Key>: Error {
        case notFound(key: Key)
        case wrongType(key: Key)
    }

    func validatedValue<T>(key: Key) throws -> T {
        guard let maybeValue = self[key] else {
            throw ValidationError.notFound(key: key)
        }

        guard let value = maybeValue as? T else {
            throw ValidationError.wrongType(key: key)
        }
        return value
    }

    func optionalValue<T>(key: Key) -> T? {
        return self[key] as? T
    }

    func removing(key: Key) -> Dictionary<Key, Value> {
        var dict = self
        dict.removeValue(forKey: key)
        return dict
    }
}
