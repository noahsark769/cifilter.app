//
//  CustomErrorProcessor.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/29/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation
import CoreImage

enum CustomErrorProcessor {
    enum ProcessorResult {
        case proceed
        case doNotProceed
        case doNotProceedAndShowError(error: String)
    }

    static func process(filterInfo: FilterInfo, filter: CIFilter) -> ProcessorResult {
        if filterInfo.name == "CIQRCodeGenerator" {
            if let correctionLevel = filter.value(forKey: "inputCorrectionLevel") as? String {
                if correctionLevel == "" {
                    return .doNotProceed
                }
                if !["L", "M", "Q", "H"].contains(correctionLevel) {
                    return .doNotProceedAndShowError(error:  "inputCorrectionLevel for CIQRCodeGenerator must be one of: L, M, Q, or H")
                }
            }
        }
        if filterInfo.name == "CIAztecCodeGenerator" {
            if let compactStyle = filter.value(forKey: "inputCompactStyle") as? NSNumber {
                if compactStyle != 0 && compactStyle != 1 {
                    return .doNotProceedAndShowError(error: "inputCompactStyle for CIAztecCodeGenerator must be one of: 0, 1")
                }
            }
        }
        return .proceed
    }
}
