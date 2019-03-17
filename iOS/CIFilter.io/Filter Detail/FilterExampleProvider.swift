//
//  FilterExampleProvider.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/8/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import Foundation

enum FilterExampleState {
    case available
    case notAvailable(reason: String)

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
        case "CIAffineClamp":
            return .notAvailable(reason: "CIFilter.io does not currently support capturing affine transform data.")
        case "CICoreMLModelFilter":
            return .notAvailable(reason: "CIFilter.io does not currently support capturing CoreML model data.")
        default:
            return .available
        }
    }
}
