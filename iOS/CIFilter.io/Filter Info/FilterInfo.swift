//
//  FilterInfo.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/12/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import Foundation
import CoreImage

struct FilterInfo: Encodable, Equatable {
    let categories: [String]
    let availableMac: String
    let availableIOS: String
    let displayName: String
    let description: String?
    let referenceDocumentation: URL
    let name: String
    let parameters: [FilterParameterInfo]

    init(filter: CIFilter) throws {
        let filterAttributeDict = filter.attributes
        categories = try filterAttributeDict.validatedValue(key: kCIAttributeFilterCategories)
        availableIOS = try filterAttributeDict.validatedValue(key: kCIAttributeFilterAvailable_iOS)
        availableMac = try filterAttributeDict.validatedValue(key: kCIAttributeFilterAvailable_Mac)
        displayName = try filterAttributeDict.validatedValue(key: kCIAttributeFilterDisplayName)
        referenceDocumentation = try filterAttributeDict.validatedValue(key: kCIAttributeReferenceDocumentation)
        name = try filterAttributeDict.validatedValue(key: kCIAttributeFilterName)
        description = CIFilter.localizedDescription(forFilterName: filter.name)

        var resultParameters: [FilterParameterInfo] = []
        var keysParsed = 6
        let keysToCheck = Set(FilterParameterInfo.filterParameterKeys).union(Set(
            filterAttributeDict.keys.filter({
                $0.starts(with: "input") || $0.starts(with: "output")
            })
        ))
        for paramKey in keysToCheck.sorted() {
            if let parameterDict = filterAttributeDict[paramKey] {
                guard let parameterDict = parameterDict as? [String: Any] else {
                    throw FilterInfoConstructionError.parameterNotDict
                }
                keysParsed += 1
                resultParameters.append(try FilterParameterInfo(filterAttributeDict: parameterDict, name: paramKey))
            }
        }
        parameters = resultParameters

        if keysParsed != filterAttributeDict.keys.count {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }
}
