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

struct FilterTransformParameterInfo {
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

struct FilterVectorParameterInfo {
    let defaultValue: CIVector
    let identity: CIVector?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = try filterAttributeDict.validatedValue(key: kCIAttributeDefault)
        identity = filterAttributeDict.optionalValue(key: kCIAttributeIdentity)

        if filterAttributeDict.count > 2 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }
}

struct FilterDataParameterInfo {
    let defaultValue: Data?
    let identity: Data?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = try filterAttributeDict.optionalValue(key: kCIAttributeDefault)
        identity = filterAttributeDict.optionalValue(key: kCIAttributeIdentity)

        if filterAttributeDict.count > 2 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }
}

struct FilterColorParameterInfo {
    let defaultValue: CIColor

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = try filterAttributeDict.validatedValue(key: kCIAttributeDefault)

        if filterAttributeDict.count > 1 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }
}

struct FilterNumberParameterInfo<T> {
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

struct FilterTimeParameterInfo {
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
        throw FilterInfoConstructionError.noParameterType
    }
}

enum FilterParameterType {
    case time(info: FilterTimeParameterInfo)
    case scalar(info: FilterNumberParameterInfo<Float>)
    case distance(info: FilterNumberParameterInfo<Float>)
    case unspecifiedNumber(info: FilterNumberParameterInfo<Float>)
    case unspecifiedVector(info: FilterVectorParameterInfo)
    case angle(info: FilterNumberParameterInfo<Float>)
    case boolean
    case integer
    case count(info: FilterNumberParameterInfo<Int>)
    case image
    case gradientImage
    case attributedString
    case data(info: FilterDataParameterInfo)
    case barcode
    case cameraCalibrationData
    case color(info: FilterColorParameterInfo)
    case position(info: FilterVectorParameterInfo)
    case transform(info: FilterTransformParameterInfo)
    case rectangle(info: FilterVectorParameterInfo)
    case unspecifiedObject

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
            throw FilterInfoConstructionError.invalidParameterType
        case kCIAttributeTypeInteger:
            throw FilterInfoConstructionError.invalidParameterType
        case kCIAttributeTypeCount:
            self = .count(info: try FilterNumberParameterInfo(filterAttributeDict: specificDict))
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
        case kCIAttributeTypeOpaqueColor:
            self = .color(info: try FilterColorParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_UnspecifiedVectorType":
            self = .unspecifiedVector(info: try FilterVectorParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_UnspecifiedObjectType":
            self = .unspecifiedObject
            if filterAttributeDict.count > 0 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        default:
            throw FilterInfoConstructionError.invalidParameterType
        }
    }
}

struct FilterParameterInfo {
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

struct FilterInfo {
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
