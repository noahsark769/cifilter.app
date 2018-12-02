//
//  FilterInfoConstructionError.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/27/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import Foundation

enum FilterInfoConstructionError: Error {
    case allKeysNotParsed
    case parameterNotDict
    case noParameterType
    case invalidParameterType
}
