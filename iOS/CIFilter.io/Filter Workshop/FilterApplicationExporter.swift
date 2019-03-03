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

/**
 * Takes one application of a filter (a unique set of input params and an output image) and exports
 * them to disk.
 */
final class FilterApplicationExporter {
    // Reserved for configuration
    init() {}

    func export(outputImage: RenderingResult, parameters: [String: Any], filterName: String) {
        let images = parameters.filter { $1 is CIImage }
        var nonImages = parameters.filter { !($1 is CIImage) }

        for (key, value) in nonImages {
            if value is NSNumber || value is NSString {
                continue
            } else {
                // TODO: log error
                print("Uh oh! \(key) was not a valid type")
                print("You might want to do something about that")
            }
        }

        print(images)

        do {
            let uuid = UUID()
            let destinationDirectory = FileManager.default.documentsDirectory
                .appendingPathComponent("export")
                .appendingPathComponent(filterName)
                .appendingPathComponent("\(uuid)")
            try FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true, attributes: nil)

            for (key, image) in images {
                guard let image = image as? CIImage else { continue }
                guard let result = RenderingResult(
                    renderingFrom: image,
                    maximumExtent: CGRect(x: 0, y: 0, width: 500, height: 500)
                ) else {
                    print("Uh oh! Could not render exported png for \(filterName) \(key)")
                    print("You might want to do something about that")
                    continue
                }
                let imageFilename = "\(key).png"
                FileManager.default.createFile(
                    atPath: destinationDirectory.appendingPathComponent(imageFilename).path,
                    contents: result.image.pngData(),
                    attributes: nil
                )
                nonImages[key] = [
                    "type": "image",
                    "image": imageFilename,
                    "wasCropped": result.wasCropped
                ]
            }

            let outputImageFilename = "outputImage.png"
            nonImages["outputImage"] = [
                "type": "image",
                "image": outputImageFilename,
                "wasCropped": outputImage.wasCropped
            ]

            let metadata: [String: Any] = [
                "$metadataVersion": 1,
                "$timeCreated": Date().timeIntervalSince1970,
                "$iOSVersionOfGeneration": UIDevice.current.systemVersion,
                "$CIFilter.ioShaOfGeneration": AppDelegate.shared.sha(),
                "$CIFilter.ioVersionOfGeneration": AppDelegate.shared.appVersion()
            ]
            nonImages["_metadata"] = metadata

            FileManager.default.createFile(
                atPath: destinationDirectory.appendingPathComponent("metadata.json").path,
                contents: try JSONSerialization.data(withJSONObject: nonImages, options: []),
                attributes: nil
            )

            FileManager.default.createFile(
                atPath: destinationDirectory.appendingPathComponent(outputImageFilename).path,
                contents: outputImage.image.pngData(),
                attributes: nil
            )
            print("Export success")
        } catch {
            print("Uh oh! Encountered an error serializing json: \(error)")
            print("You might want to do something about that")
        }
    }
}
