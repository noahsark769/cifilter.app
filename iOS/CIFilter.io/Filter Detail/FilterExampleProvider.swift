//
//  FilterExampleProvider.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/8/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import Foundation

enum FilterExampleState: Equatable {
    case available
    case notAvailable(reason: String, associatedLink: URL?)

    static func notAvailable(reason: String) -> FilterExampleState {
        return .notAvailable(reason: reason, associatedLink: nil)
    }

    var isAvailable: Bool {
        switch self {
        case .available: return true
        default: return false
        }
    }
}

// TODO: Rename this class, it doesn't provide examples of filters
final class FilterExampleProvider {
    func state(forFilterName filterName: String) -> FilterExampleState {
        switch filterName {
        case "CIDepthBlurEffect":
            return .notAvailable(reason: "CIFilter.io does not currently support capturing depth and camera calibration data.")
        case "CICameraCalibrationLensCorrection":
            return .notAvailable(reason: "CIFilter.io does not currently support capturing camera calibration data.")
        case "CIColorCube": fallthrough
        case "CIColorCubesMixedWithMask": fallthrough
        case "CIColorCubeWithColorSpace":
            return .notAvailable(reason: "CIFilter.io does not currently support capturing color cube data.")
        case "CIColorCurves":
            return .notAvailable(reason: "CIFilter.io does not currently support capturing color curve data.")
        case "CIAttributedTextImageGenerator":
            return .notAvailable(reason: "CIFilter.io does not currently support capturing attributed text.")
        case "CIBarcodeGenerator":
            return .notAvailable(reason: "CIFilter.io does not currently support capturing an abstract CIBarcodeDescriptor. If you'd like, please see other generator filters such as CIQRCodeGenerator, CIPDF417CodeGenerator, and CIAztecCodeGenerator. CIFilter.io does not support generating Data Matrix codes at this time.")
        case "CIMeshGenerator":
            return .notAvailable(reason: "CIFilter.io does not currently support capturing mesh array data.")
        case "CIAffineTransform": fallthrough
        case "CIAffineClamp": fallthrough
        case "CIAffineTile":
            return .notAvailable(reason: "CIFilter.io does not currently support capturing affine transform data.")
        case "CICoreMLModelFilter":
            return .notAvailable(reason: "CIFilter.io does not currently support capturing CoreML model data.")
        case "CIConvolution3X3": fallthrough
        case "CIConvolution5X5": fallthrough
        case "CIConvolution7X7": fallthrough
        case "CIConvolution9Horizontal": fallthrough
        case "CIConvolution9Vertical":
            return .notAvailable(reason: "CIFilter.io does not currently support capturing convolutional weight data.")
        case "CIKMeans":
            // There's a bug with CIKMeans that only affects iOS 13. CIKMeans was introduced in iOS
            // 13, so until this bug gets solved or I understand how to work around it
            if ProcessInfo().operatingSystemVersion.majorVersion == 13 {
                return .notAvailable(reason: "CIKMeans has a bug in iOS 13 that results in crashes.", associatedLink: URL(string: "https://stackoverflow.com/questions/61891134/coreimage-cikmeans-cifilter-exception")!)
            } else {
                return .available
            }
        default:
            return .available
        }
    }
}
