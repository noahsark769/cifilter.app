//
//  FilterInfo.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/12/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import Foundation
import CoreImage

enum FilterInfoConstructionError: Error {
    case allKeysNotParsed
    case parameterNotDict
    case noParameterType
    case invalidParameterType
}

enum ValidationError<Key>: Error {
    case notFound(key: Key)
    case wrongType(key: Key)
}

extension Dictionary {
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

struct FilterTransformParameterInfo: Codable {
    let defaultValue: CGAffineTransform
    let identity: CGAffineTransform

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = try filterAttributeDict.validatedValue(key: kCIAttributeDefault)
        identity = try filterAttributeDict.validatedValue(key: kCIAttributeIdentity)

        if filterAttributeDict.count > 2 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }
}

struct CIVectorCodableWrapper: Codable {
    let vector: CIVector

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var floats: [CGFloat] = []
        while !container.isAtEnd {
            floats.append(try container.decode(CGFloat.self))
        }
        var unsafePointer: UnsafePointer<CGFloat>? = nil
        floats.withUnsafeBufferPointer { unsafeBufferPointer in
            unsafePointer = unsafeBufferPointer.baseAddress!
        }
        vector = CIVector(values: unsafePointer!, count: container.count!)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<vector.count {
            try container.encode(vector.value(at: i))
        }
    }
}

struct FilterVectorParameterInfo: Codable {
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
}

struct FilterDataParameterInfo: Codable {
    let defaultValue: Data?
    let identity: Data?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = filterAttributeDict.optionalValue(key: kCIAttributeDefault)
        identity = filterAttributeDict.optionalValue(key: kCIAttributeIdentity)

        if filterAttributeDict.count > 2 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }
}

struct FilterColorParameterInfo: Encodable {
    let defaultValue: CGColorSpace
    let identity: CGColorSpace?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = try filterAttributeDict.validatedValue(key: kCIAttributeDefault)
        identity = filterAttributeDict.optionalValue(key: kCIAttributeIdentity)

        if filterAttributeDict.count > 2 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }

    func encode(to encoder: Encoder) throws {

    }
}

struct FilterUnspecifiedObjectParameterInfo: Encodable {
    let defaultValue: NSObject?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = filterAttributeDict.optionalValue(key: kCIAttributeDefault)

        if filterAttributeDict.count > 1 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }

    func encode(to encoder: Encoder) throws {

    }
}

struct FilterStringParameterInfo: Codable {
    let defaultValue: String?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = filterAttributeDict.optionalValue(key: kCIAttributeDefault)

        if filterAttributeDict.count > 1 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }
}

struct FilterNumberParameterInfo<T: Codable>: Codable {
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
}

struct FilterTimeParameterInfo: Codable {
    let numberInfo: FilterNumberParameterInfo<Float>
    let identity: Float

    init(filterAttributeDict: [String: Any]) throws {
        identity = try filterAttributeDict.validatedValue(key: kCIAttributeIdentity)
        numberInfo = try FilterNumberParameterInfo(filterAttributeDict: filterAttributeDict.removing(key: kCIAttributeIdentity))
    }
}

private func filterParameterType(forAttributesDict dict: [String: Any], className: String) throws -> String {
    if let parameterTypeString: String = dict.optionalValue(key: kCIAttributeType) {
        return parameterTypeString
    } else {
        if dict[kCIAttributeDefault] is CGAffineTransform {
            return "CIFilter.io_TransformType"
        }
        if className == "NSAttributedString" {
            return "CIFilter.io_AttributedStringType"
        }
        if className == "NSNumber" {
            return "CIFilter.io_UnspecifiedNumberType"
        }
        if className == "NSData" {
            return "CIFilter.io_DataType"
        }
        if className == "CIBarcodeDescriptor" {
            return "CIFilter.io_BarcodeDescriptorType"
        }
        if className == "AVCameraCalibrationData" {
            return "CIFilter.io_CameraCalibrationDataType"
        }
        if className == "CIColor" {
            return "CIFilter.io_ColorType"
        }
        if className == "CIVector" {
            return "CIFilter.io_UnspecifiedVectorType"
        }
        if className == "NSObject" {
            return "CIFilter.io_UnspecifiedObjectType"
        }
        if className == "MLModel" {
            return "CIFilter.io_MLModelType"
        }
        if className == "NSString" {
            return "CIFilter.io_StringType"
        }
        if className == "CIImage" {
            return "CIFilter.io_UnkeyedImageType"
        }
        if className == "CGImageMetadataRef" {
            return "CIFilter.io_CGImageMetadataRefType"
        }
        if className == "NSArray" {
            return "CIFilter.io_ArrayType"
        }
        throw FilterInfoConstructionError.noParameterType
    }
}

enum FilterParameterType: Encodable  {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawType)
    }

    case time(info: FilterTimeParameterInfo)
    case scalar(info: FilterNumberParameterInfo<Float>)
    case distance(info: FilterNumberParameterInfo<Float>)
    case unspecifiedNumber(info: FilterNumberParameterInfo<Float>)
    case unspecifiedVector(info: FilterVectorParameterInfo)
    case angle(info: FilterNumberParameterInfo<Float>)
    case boolean(info: FilterNumberParameterInfo<Int>)
    case integer
    case count(info: FilterNumberParameterInfo<Int>)
    case image
    case gradientImage
    case attributedString
    case data(info: FilterDataParameterInfo)
    case barcode
    case cameraCalibrationData
    case color(info: FilterColorParameterInfo)
    case opaqueColor(info: FilterColorParameterInfo)
    case position(info: FilterVectorParameterInfo)
    case position3(info: FilterVectorParameterInfo)
    case transform(info: FilterTransformParameterInfo)
    case rectangle(info: FilterVectorParameterInfo)
    case unspecifiedObject(info: FilterUnspecifiedObjectParameterInfo)
    case mlModel
    case string(info: FilterStringParameterInfo)
    case cgImageMetadata
    case offset(info: FilterVectorParameterInfo)
    case array

    enum RawType: String, Encodable {
        case time
        case scalar
        case distance
        case unspecifiedNumber
        case unspecifiedVector
        case angle
        case boolean
        case integer
        case count
        case image
        case gradientImage
        case attributedString
        case data
        case barcode
        case cameraCalibrationData
        case color
        case opaqueColor
        case position
        case position3
        case transform
        case rectangle
        case unspecifiedObject
        case mlModel
        case string
        case cgImageMetadata
        case offset
        case array
    }

    var rawType: RawType {
        switch self {
        case .time: return .time
        case .scalar: return .scalar
        case .distance: return .distance
        case .unspecifiedNumber: return .unspecifiedNumber
        case .unspecifiedVector: return .unspecifiedVector
        case .angle: return .angle
        case .boolean: return .boolean
        case .integer: return .integer
        case .count: return .count
        case .image: return .image
        case .gradientImage: return .gradientImage
        case .attributedString: return .attributedString
        case .data: return .data
        case .barcode: return .barcode
        case .cameraCalibrationData: return .cameraCalibrationData
        case .color: return .color
        case .opaqueColor: return .opaqueColor
        case .position: return .position
        case .position3: return .position3
        case .transform: return .transform
        case .rectangle: return .rectangle
        case .unspecifiedObject: return .unspecifiedObject
        case .mlModel: return .mlModel
        case .string: return .string
        case .cgImageMetadata: return .cgImageMetadata
        case .offset: return .offset
        case .array: return .array
        }
    }

    init(filterAttributeDict: [String: Any], className: String) throws {
        let parameterTypeString = try filterParameterType(forAttributesDict: filterAttributeDict, className: className)
        var specificDict = filterAttributeDict
        specificDict.removeValue(forKey: kCIAttributeType)
        switch parameterTypeString {
        case kCIAttributeTypeTime:
            self = .time(info: try FilterTimeParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeScalar:
            self = .scalar(info: try FilterNumberParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeDistance:
            self = .distance(info: try FilterNumberParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeAngle:
            self = .angle(info: try FilterNumberParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeBoolean:
            self = .boolean(info: try FilterNumberParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeInteger:
            throw FilterInfoConstructionError.invalidParameterType
        case kCIAttributeTypeCount:
            self = .count(info: try FilterNumberParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_UnkeyedImageType":
            fallthrough
        case kCIAttributeTypeImage:
            self = .image
            if filterAttributeDict.count > 1 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        case "CIFilter.io_UnspecifiedNumberType":
            self = .unspecifiedNumber(info: try FilterNumberParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_TransformType":
            fallthrough
        case kCIAttributeTypeTransform:
            self = .transform(info: try FilterTransformParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeRectangle:
            self = .rectangle(info: try FilterVectorParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypePosition:
            self = .position(info: try FilterVectorParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypePosition3:
            self = .position3(info: try FilterVectorParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeOffset:
            self = .offset(info: try FilterVectorParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeGradient:
            self = .gradientImage
            if filterAttributeDict.count > 1 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        case "CIFilter.io_AttributedStringType":
            self = .attributedString
            if filterAttributeDict.count > 0 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        case "CIFilter.io_DataType":
            self = .data(info: try FilterDataParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_BarcodeDescriptorType":
            self = .barcode
            if filterAttributeDict.count > 0 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        case "CIFilter.io_CameraCalibrationDataType":
            self = .cameraCalibrationData
            if filterAttributeDict.count > 0 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        case "CIFilter.io_ColorType":
            fallthrough
        case kCIAttributeTypeColor:
            self = .color(info: try FilterColorParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeOpaqueColor:
            self = .opaqueColor(info: try FilterColorParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_UnspecifiedVectorType":
            self = .unspecifiedVector(info: try FilterVectorParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_UnspecifiedObjectType":
            self = .unspecifiedObject(info: try FilterUnspecifiedObjectParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_MLModelType":
            self = .mlModel
            if filterAttributeDict.count > 0 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        case "CIFilter.io_StringType":
            self = .string(info: try FilterStringParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_CGImageMetadataRefType":
            self = .cgImageMetadata
            if filterAttributeDict.count > 0 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        case "CIFilter.io_ArrayType":
            self = .array
            if filterAttributeDict.count > 0 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        default:
            throw FilterInfoConstructionError.invalidParameterType
        }
    }
}

struct FilterParameterInfo: Encodable {
    let classType: String
    let description: String?
    let displayName: String
    let type: FilterParameterType

    init(filterAttributeDict: [String: Any]) throws {
        classType = try filterAttributeDict.validatedValue(key: kCIAttributeClass)
        description = filterAttributeDict.optionalValue(key: kCIAttributeDescription)
        displayName = try filterAttributeDict.validatedValue(key: kCIAttributeDisplayName)

        var parameterSpecificDict = filterAttributeDict
        parameterSpecificDict.removeValue(forKey: kCIAttributeClass)
        parameterSpecificDict.removeValue(forKey: kCIAttributeDescription)
        parameterSpecificDict.removeValue(forKey: kCIAttributeDisplayName)

        type = try FilterParameterType(filterAttributeDict: parameterSpecificDict, className: try filterAttributeDict.validatedValue(key: kCIAttributeClass))
    }
}

extension FilterParameterInfo {
    static let filterParameterKeys = [
        kCIOutputImageKey,
        kCIInputBackgroundImageKey,
        kCIInputImageKey,
        kCIInputTimeKey,
        kCIInputDepthImageKey,
        kCIInputDisparityImageKey,
        kCIInputTransformKey,
        kCIInputScaleKey,
        kCIInputAspectRatioKey,
        kCIInputCenterKey,
        kCIInputRadiusKey,
        kCIInputAngleKey,
        kCIInputRefractionKey,
        kCIInputWidthKey,
        kCIInputSharpnessKey,
        kCIInputIntensityKey,
        kCIInputEVKey,
        kCIInputSaturationKey,
        kCIInputColorKey,
        kCIInputBrightnessKey,
        kCIInputContrastKey,
        kCIInputWeightsKey,
        kCIInputGradientImageKey,
        kCIInputMaskImageKey,
        kCIInputShadingImageKey,
        kCIInputTargetImageKey,
        kCIInputExtentKey,
        kCIInputVersionKey
    ]
}

struct FilterInfo: Encodable {
    let categories: [String]
    let availableMac: String
    let availableIOS: String
    let displayName: String
    let referenceDocumentation: URL
    let name: String
    let parameters: [FilterParameterInfo]

    init(filterAttributeDict: [String: Any]) throws {
        categories = try filterAttributeDict.validatedValue(key: kCIAttributeFilterCategories)
        availableIOS = try filterAttributeDict.validatedValue(key: kCIAttributeFilterAvailable_iOS)
        availableMac = try filterAttributeDict.validatedValue(key: kCIAttributeFilterAvailable_Mac)
        displayName = try filterAttributeDict.validatedValue(key: kCIAttributeFilterDisplayName)
        referenceDocumentation = try filterAttributeDict.validatedValue(key: kCIAttributeReferenceDocumentation)
        name = try filterAttributeDict.validatedValue(key: kCIAttributeFilterName)

        var resultParameters: [FilterParameterInfo] = []
        var keysParsed = 6
        let keysToCheck = Set(FilterParameterInfo.filterParameterKeys).union(Set(
            filterAttributeDict.keys.filter({
                $0.starts(with: "input") || $0.starts(with: "output")
            })
        ))
        for paramKey in keysToCheck {
            if let parameterDict = filterAttributeDict[paramKey] {
                guard let parameterDict = parameterDict as? [String: Any] else {
                    throw FilterInfoConstructionError.parameterNotDict
                }
                keysParsed += 1
                resultParameters.append(try FilterParameterInfo(filterAttributeDict: parameterDict))
            }
        }
        parameters = resultParameters

        if keysParsed != filterAttributeDict.keys.count {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }
}
