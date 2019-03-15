//
//  FilterApplicationExporter.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 3/2/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

extension FileManager {
    var documentsDirectory: URL {
        return self.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
}

struct AnyEncodable: Encodable {
    var value: Encodable

    init(_ value: Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

struct ExportMetadata: Encodable {
    let version: Int
    let timeCreated: TimeInterval
    let iosVersionOfGeneration: String
    let shaOfGeneration: String
    let appVersionOfGeneration: String
}

protocol ExportType: Encodable {}

struct ExportInt: ExportType {
    let value: Int
}

struct ExportDouble: ExportType {
    let value: Double
}

struct ExportImage: ExportType {
    let image: String
    let wasCropped: Bool
}

struct ExportVector: ExportType {
    let value: CIVectorCodableWrapper
}

struct ExportColor: ExportType {
    let value: CIColor

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(UIColor(ciColor: value).toHexString())
    }
}

struct ExportParameterValue: Encodable {
    let type: String
    let name: String
    let additionalData: AnyEncodable
}

struct ExportExample: Encodable {
    let metadata: ExportMetadata
    let parameterValues: [ExportParameterValue]

    enum CodingKeys: String, CodingKey {
        case metadata = "_metadata"
        case parameterValues
    }
}

extension ExportParameterValue {
    init(name: String, int: Int) {
        self.init(type: "number", name: name, additionalData: AnyEncodable(ExportInt(value: int)))
    }

    init(name: String, double: Double) {
        self.init(type: "number", name: name, additionalData: AnyEncodable(ExportDouble(value: double)))
    }

    init(name: String, color: CIColor) {
        self.init(type: "color", name: name, additionalData: AnyEncodable(ExportColor(value: color)))
    }

    init(name: String, image: String, wasCropped: Bool) {
        self.init(type: "image", name: name, additionalData: AnyEncodable(ExportImage(image: image, wasCropped: wasCropped)))
    }

    init(name: String, vector: CIVector) {
        self.init(type: "vector", name: name, additionalData: AnyEncodable(ExportVector(value: CIVectorCodableWrapper(vector: vector))))
    }
}

/**
 * Takes one application of a filter (a unique set of input params and an output image) and exports
 * them to disk.
 */
final class FilterApplicationExporter {
    // Reserved for configuration
    init() {}

    static func exportToFilesystem(image: CIImage, filterName: String, parameterName: String, exportId: UUID) -> ExportParameterValue {
        guard let result = RenderingResult(
            renderingFrom: image,
            maximumExtent: CGRect(x: 0, y: 0, width: 500, height: 500)
            ) else {
                fatalError("Uh oh! Could not render exported png for \(filterName) \(parameterName)")
        }
        return FilterApplicationExporter.exportToFilesystem(renderingResult: result, filterName: filterName, parameterName: parameterName, exportId: exportId)
    }

    static func exportToFilesystem(renderingResult result: RenderingResult, filterName: String, parameterName: String, exportId: UUID) -> ExportParameterValue {
        let destinationDirectory = FileManager.default.documentsDirectory
            .appendingPathComponent("export")
            .appendingPathComponent(filterName)
            .appendingPathComponent("\(exportId)")
        try! FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true, attributes: nil)
        let imageFilename = "\(parameterName).png"
        FileManager.default.createFile(
            atPath: destinationDirectory.appendingPathComponent(imageFilename).path,
            contents: result.image.pngData(),
            attributes: nil
        )

        return ExportParameterValue(name: parameterName, image: imageFilename, wasCropped: result.wasCropped)
    }

    static func transformParameterValues(_ original: [String: Any], filterName: String, exportId: UUID) -> [ExportParameterValue] {
        var result = [ExportParameterValue]()
        for (key, value) in original {
            switch value {
            case let image as CIImage:
                result.append(FilterApplicationExporter.exportToFilesystem(
                    image: image,
                    filterName: filterName,
                    parameterName: key,
                    exportId: exportId
                ))
            case let value as Int:
                result.append(ExportParameterValue(name: key, int: value))
            case let ciColor as CIColor:
                result.append(ExportParameterValue(name: key, color: ciColor))
            case let ciVector as CIVector:
                result.append(ExportParameterValue(name: key, vector: ciVector))
            case let double as Double:
                result.append(ExportParameterValue(name: key, double: double))
            case let float as Float:
                result.append(ExportParameterValue(name: key, double: Double(float)))
            default:
                fatalError("Could not map value of type \(type(of: value)): \(value)")
            }
        }
        return result
    }

    func export(outputImage: RenderingResult, parameters: [String: Any], filterName: String) {
        let encoder = JSONEncoder()
        let exportId = UUID()
        var exportParameterValues = FilterApplicationExporter.transformParameterValues(parameters, filterName: filterName, exportId: exportId)
        exportParameterValues.append(FilterApplicationExporter.exportToFilesystem(renderingResult: outputImage, filterName: filterName, parameterName: "outputImage", exportId: exportId))

        let metadata = ExportMetadata(
            version: 1,
            timeCreated: Date().timeIntervalSince1970,
            iosVersionOfGeneration: UIDevice.current.systemVersion,
            shaOfGeneration: AppDelegate.shared.sha(),
            appVersionOfGeneration: AppDelegate.shared.appVersion()
        )
        let exportExample = ExportExample(metadata: metadata, parameterValues: exportParameterValues)
        let destinationDirectory = FileManager.default.documentsDirectory
            .appendingPathComponent("export")
            .appendingPathComponent(filterName)
            .appendingPathComponent("\(exportId)")
        FileManager.default.createFile(
            atPath: destinationDirectory.appendingPathComponent("metadata.json").path,
            contents: try! encoder.encode(exportExample),
            attributes: nil
        )
        print("Export success")
    }
}
