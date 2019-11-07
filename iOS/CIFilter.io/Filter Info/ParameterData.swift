//
//  ParameterData.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/27/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import Foundation
import CoreImage

#if targetEnvironment(macOS)
import AppKit // Needed for NSAffineTransform
#endif

protocol FilterInformationalStringConvertible {
    var informationalDescription: String? { get }
}

struct FilterTransformParameterInfo: Codable, FilterInformationalStringConvertible {
    #if !targetEnvironment(macCatalyst)
    let defaultValue: CGAffineTransform
    let identity: CGAffineTransform
    #endif

    init(filterAttributeDict: [String: Any]) throws {
        // TODO(UIKitForMac): Write a Decodable wrapper around NSAffineTransform, since it's not
        // Codable
        #if !targetEnvironment(macCatalyst)
        defaultValue = try filterAttributeDict.validatedValue(key: kCIAttributeDefault)
        identity = try filterAttributeDict.validatedValue(key: kCIAttributeIdentity)
        #endif
        if filterAttributeDict.count > 2 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }

    var informationalDescription: String? {
        #if targetEnvironment(macCatalyst)
        return nil
        #else
        return "Default: " + String(describing: defaultValue)
        #endif
    }
}

struct FilterVectorParameterInfo: Codable, FilterInformationalStringConvertible {
    let defaultValue: CIVectorCodableWrapper?
    let identity: CIVectorCodableWrapper?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = filterAttributeDict.optionalValue(key: kCIAttributeDefault)
        identity = filterAttributeDict.optionalValue(key: kCIAttributeIdentity)

        if filterAttributeDict.count > 2 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }

    enum CodingKeys: String, CodingKey {
        case defaultValue
        case identity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultValue = try container.decodeIfPresent(CIVectorCodableWrapper.self, forKey: .defaultValue)
        identity = try container.decodeIfPresent(CIVectorCodableWrapper.self, forKey: .identity)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(defaultValue, forKey: .defaultValue)
        try container.encode(identity, forKey: .identity)
    }

    var informationalDescription: String? {
        guard let defaultValue = self.defaultValue else {
            return nil
        }
        return "Default: " + String(describing: defaultValue)
    }
}

struct FilterDataParameterInfo: Codable, FilterInformationalStringConvertible {
    let defaultValue: Data?
    let identity: Data?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = filterAttributeDict.optionalValue(key: kCIAttributeDefault)
        identity = filterAttributeDict.optionalValue(key: kCIAttributeIdentity)

        if filterAttributeDict.count > 2 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }

    var informationalDescription: String? {
        return defaultValue.flatMap { _ in "Has default value." }
    }
}

struct FilterColorParameterInfo: Encodable, FilterInformationalStringConvertible {
    let defaultValue: CIColor
    let identity: CIColor?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = try filterAttributeDict.validatedValue(key: kCIAttributeDefault)
        identity = filterAttributeDict.optionalValue(key: kCIAttributeIdentity)

        if filterAttributeDict.count > 2 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }

    func encode(to encoder: Encoder) throws {
        // Do nothing here. We ignore this info for encoding (since CIColor and CGColorSpace aren't
        // codable).
    }

    var informationalDescription: String? {
        // Apparently, no filters exist with input colors which don't have default values.
        return "Has default value."
    }
}

struct FilterUnspecifiedObjectParameterInfo: Encodable, FilterInformationalStringConvertible {
    let defaultValue: NSObject?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = filterAttributeDict.optionalValue(key: kCIAttributeDefault)

        if filterAttributeDict.count > 1 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }

    func encode(to encoder: Encoder) throws {

    }

    var informationalDescription: String? {
        return defaultValue.flatMap { _ in "Has default value." }
    }
}

struct FilterStringParameterInfo: Codable, FilterInformationalStringConvertible {
    let defaultValue: String?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = filterAttributeDict.optionalValue(key: kCIAttributeDefault)

        if filterAttributeDict.count > 1 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }

    var informationalDescription: String? {
        return defaultValue.flatMap { "Default: \($0)" }
    }
}

struct FilterNumberParameterInfo<T: Codable>: Codable, FilterInformationalStringConvertible {
    let minValue: T?
    let maxValue: T?
    let defaultValue: T?
    let sliderMin: T?
    let sliderMax: T?
    let identity: T?

    init(filterAttributeDict: [String: Any]) throws {
        minValue = filterAttributeDict.optionalValue(key: kCIAttributeMin)
        maxValue = filterAttributeDict.optionalValue(key: kCIAttributeMax)
        defaultValue = filterAttributeDict.optionalValue(key: kCIAttributeDefault)
        sliderMin = filterAttributeDict.optionalValue(key: kCIAttributeSliderMin)
        sliderMax = filterAttributeDict.optionalValue(key: kCIAttributeSliderMax)
        identity = filterAttributeDict.optionalValue(key: kCIAttributeIdentity)

        if filterAttributeDict.count > 6 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }

    var informationalDescription: String? {
        return [
            minValue.flatMap { "Min: \($0)" },
            maxValue.flatMap { "Max: \($0)" }
        ].compactMap({ $0 }).joined(separator: " ")
    }
}

struct FilterTimeParameterInfo: Codable, FilterInformationalStringConvertible {
    let numberInfo: FilterNumberParameterInfo<Float>
    let identity: Float

    init(filterAttributeDict: [String: Any]) throws {
        identity = try filterAttributeDict.validatedValue(key: kCIAttributeIdentity)
        numberInfo = try FilterNumberParameterInfo(filterAttributeDict: filterAttributeDict.removing(key: kCIAttributeIdentity))
    }

    var informationalDescription: String? {
        return numberInfo.informationalDescription
    }
}
