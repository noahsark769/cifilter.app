//
//  FilterParameterInfo.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/27/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import Foundation
import CoreImage

struct FilterParameterInfo: Encodable {
    let classType: String
    let description: String?
    let displayName: String
    let name: String
    let type: FilterParameterType

    init(filterAttributeDict: [String: Any], name: String) throws {
        classType = try filterAttributeDict.validatedValue(key: kCIAttributeClass)
        description = filterAttributeDict.optionalValue(key: kCIAttributeDescription)
        displayName = try filterAttributeDict.validatedValue(key: kCIAttributeDisplayName)
        self.name = name

        var parameterSpecificDict = filterAttributeDict
        parameterSpecificDict.removeValue(forKey: kCIAttributeClass)
        parameterSpecificDict.removeValue(forKey: kCIAttributeDescription)
        parameterSpecificDict.removeValue(forKey: kCIAttributeDisplayName)

        type = try FilterParameterType(filterAttributeDict: parameterSpecificDict, className: try filterAttributeDict.validatedValue(key: kCIAttributeClass))
    }

    var descriptionOrDefault: String {
        return self.description ?? "No description provided by Core Image."
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
