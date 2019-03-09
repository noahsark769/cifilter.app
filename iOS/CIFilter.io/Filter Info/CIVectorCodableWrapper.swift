//
//  CIVectorCodableWrapper.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/27/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import Foundation
import CoreImage

extension CIVector {
    convenience init(floats: [CGFloat]) {
        var unsafePointer: UnsafePointer<CGFloat>? = nil
        floats.withUnsafeBufferPointer { unsafeBufferPointer in
            unsafePointer = unsafeBufferPointer.baseAddress!
        }
        self.init(values: unsafePointer!, count: floats.count)
    }
}

struct CIVectorCodableWrapper {
    let vector: CIVector
}

extension CIVectorCodableWrapper: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var floats: [CGFloat] = []
        while !container.isAtEnd {
            floats.append(try container.decode(CGFloat.self))
        }
        vector = CIVector(floats: floats)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<vector.count {
            try container.encode(vector.value(at: i))
        }
    }
}
