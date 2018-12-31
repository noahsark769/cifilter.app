//
//  FilterParameterType.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/27/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import CoreImage

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

enum FilterParameterType: Encodable, FilterInformationalStringConvertible  {
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

    var informationalDescription: String? {
        switch self {
        case let .time(info): return (info.informationalDescription ?? "")
        case let .scalar(info): return "Scalar. " + (info.informationalDescription ?? "")
        case let .distance(info): return "Distance. " + (info.informationalDescription ?? "")
        case let .unspecifiedNumber(info): return "Number." + (info.informationalDescription ?? "")
        case let .unspecifiedVector(info): return "Vector." + (info.informationalDescription ?? "")
        case let .angle(info): return "Angle. " + (info.informationalDescription ?? "")
        case let .boolean(info): return "Boolean. " + (info.informationalDescription ?? "")
        case .integer: return "Integer."
        case let .count(info): return "Count. " + (info.informationalDescription ?? "")
        case .image: return "Image."
        case .gradientImage: return "Gradient image."
        case .attributedString: return "Attributed String."
        case let .data(info): return "Data. " + (info.informationalDescription ?? "")
        case .barcode: return "Barcode descriptor."
        case .cameraCalibrationData: return "Camera calibration data."
        case let .color(info): return "Color. " + (info.informationalDescription ?? "")
        case let .opaqueColor(info): return "Opaque color. " + (info.informationalDescription ?? "")
        case let .position(info): return "Position. " + (info.informationalDescription ?? "")
        case let .position3(info): return "Position (3D). " + (info.informationalDescription ?? "")
        case let .transform(info): return "Transform. " + (info.informationalDescription ?? "")
        case let .rectangle(info): return "Rectangle. " + (info.informationalDescription ?? "")
        case let .unspecifiedObject(info): return "Object. " + (info.informationalDescription ?? "")
        case .mlModel: return "Machine learning model."
        case let .string(info): return "String. " + (info.informationalDescription ?? "")
        case .cgImageMetadata: return "Image metadata."
        case let .offset(info): return "Offset. " + (info.informationalDescription ?? "")
        case .array: return "Array."
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

