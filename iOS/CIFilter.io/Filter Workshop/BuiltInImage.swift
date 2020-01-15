//
//  BuiltInImage.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 2/2/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit
import Combine
import CoreImage.CIFilterBuiltins

extension CIImage {
    func checkerboarded() -> CIImage {
        let checkerboardFilter = CIFilter(name: "CICheckerboardGenerator", parameters: [
            "inputWidth": 40,
            "inputColor0": CIColor.white,
            "inputColor1": CIColor(color: UIColor(rgb: 0xeeeeee)),
            "inputCenter": CIVector(x: 0, y: 0),
            "inputSharpness": 1
        ])!
        let sourceOverCompositingFilter = CIFilter(name: "CISourceOverCompositing")!
        sourceOverCompositingFilter.setValue(checkerboardFilter.outputImage!, forKey: kCIInputBackgroundImageKey)
        sourceOverCompositingFilter.setValue(self, forKey: kCIInputImageKey)
        return sourceOverCompositingFilter.outputImage!
    }
}

final class BuiltInImageManager {
    enum LoadingState {
        case loading
        case loaded(image: BuiltInImage)
    }

    enum ImageType: String, CaseIterable, Identifiable {
        case knighted
        case liberty
        case paper
        case playhouse
        case shaded
        case black
        case white
        case gradient
        case skiBackground
        case skiText

        var id: String {
            return self.rawValue
        }
    }

    static let shared = BuiltInImageManager()

    let knighted = CurrentValueSubject<LoadingState, Never>(.loading)
    let liberty = CurrentValueSubject<LoadingState, Never>(.loading)
    let shaded = CurrentValueSubject<LoadingState, Never>(.loading)
    let black = CurrentValueSubject<LoadingState, Never>(.loading)
    let white = CurrentValueSubject<LoadingState, Never>(.loading)
    let gradient = CurrentValueSubject<LoadingState, Never>(.loading)
    let paper = CurrentValueSubject<LoadingState, Never>(.loading)
    let playhouse = CurrentValueSubject<LoadingState, Never>(.loading)
    let skiBackground = CurrentValueSubject<LoadingState, Never>(.loading)
    let skiText = CurrentValueSubject<LoadingState, Never>(.loading)

    func subject(forType type: ImageType) -> CurrentValueSubject<LoadingState, Never> {
        switch type {
        case .knighted: return self.knighted
        case .liberty: return self.liberty
        case .shaded: return self.shaded
        case .black: return self.black
        case .white: return self.white
        case .gradient: return self.gradient
        case .paper: return self.paper
        case .playhouse: return self.playhouse
        case .skiBackground: return self.skiBackground
        case .skiText: return self.skiText
        }
    }

    private func loadImageOnMainThread(type: ImageType, name: String, useCheckerboard: Bool) {
        DispatchQueue.main.async {
            let builtInImage = BuiltInImage(name: name, useCheckerboard: useCheckerboard)
            self.subject(forType: type).send(.loaded(image: builtInImage))
        }
    }

    private func loadImageInBackground(type: ImageType, generator: @escaping () -> (CIImage, CIImage, CGRect)) {
        DispatchQueue.global(qos: .userInitiated).async {
            let builtInImage = BuiltInImage(generator: generator)
            self.subject(forType: type).send(.loaded(image: builtInImage))
        }
    }

    func loadImages() {
        self.loadImageOnMainThread(type: .knighted, name: "knighted", useCheckerboard: false)
        self.loadImageOnMainThread(type: .liberty, name: "liberty", useCheckerboard: false)
        self.loadImageOnMainThread(type: .shaded, name: "shadedsphere", useCheckerboard: false)
        self.loadImageOnMainThread(type: .paper, name: "paper", useCheckerboard: true)
        self.loadImageOnMainThread(type: .playhouse, name: "playhouse", useCheckerboard: true)
        self.loadImageOnMainThread(type: .skiBackground, name: "ski-background", useCheckerboard: true)
        self.loadImageOnMainThread(type: .skiText, name: "ski-text", useCheckerboard: true)

        self .loadImageInBackground(type: .black) {
            let contstantColorFilter = CIFilter(name: "CIConstantColorGenerator")!
            contstantColorFilter.setValue(CIColor.black, forKey: "inputColor")
            let ciImage = contstantColorFilter.outputImage!
            return (ciImage, ciImage, CGRect(origin: .zero, size: CGSize(width: 500, height: 500)))
        }

        self.loadImageInBackground(type: .white) {
            let contstantColorFilter = CIFilter(name: "CIConstantColorGenerator")!
            contstantColorFilter.setValue(CIColor.white, forKey: "inputColor")
            let ciImage = contstantColorFilter.outputImage!
            return (ciImage, ciImage, CGRect(origin: .zero, size: CGSize(width: 500, height: 500)))
        }

        self.loadImageInBackground(type: .gradient) {
            let linearGradientFilter = CIFilter.linearGradient()
            linearGradientFilter.color0 = CIColor(red: 0, green: 0, blue: 0, alpha: 1)
            linearGradientFilter.color1 = CIColor(red: 0, green: 0, blue: 0, alpha: 0)
            linearGradientFilter.point0 = CGPoint(x: 0, y: 250)
            linearGradientFilter.point1 = CGPoint(x: 500, y: 250)
            let ciImage = linearGradientFilter.outputImage!
            return (ciImage, ciImage.checkerboarded(), CGRect(origin: .zero, size: CGSize(width: 500, height: 500)))
        }
    }
}

struct BuiltInImage: Identifiable {
    private(set) var id = UUID()

    let image: UIImage
    let imageForImageChooser: UIImage
    private static let checkerboardFilter = CIFilter(name: "CICheckerboardGenerator", parameters: [
        "inputWidth": 40,
        "inputColor0": CIColor.white,
        "inputColor1": CIColor(color: UIColor(rgb: 0xeeeeee)),
        "inputCenter": CIVector(x: 0, y: 0),
        "inputSharpness": 1
    ])!

    fileprivate init(name: String, useCheckerboard: Bool = false) {
        let uiImage = UIImage(named: name)!
        image = uiImage
        if useCheckerboard {
            let ciImage = CIImage(image: uiImage)!
            let outputImage = ciImage.checkerboarded()
            let context = CIContext()
            guard let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else {
                fatalError("Could not create built in image from ciContext")
            }
            imageForImageChooser = UIImage(cgImage: cgImage)
        } else {
            imageForImageChooser = uiImage
        }
    }

    // TODO: name is currently an unused parameter
    fileprivate init(generator: () -> (CIImage, CIImage, CGRect)) {
        let context = CIContext()
        let (ciImage, ciImageForImageChooser, extent) = generator()
        guard let cgImage = context.createCGImage(ciImage, from: extent) else {
            fatalError("Could not create built in image from ciContext")
        }
        let image = UIImage(cgImage: cgImage)
        self.image = image

        guard let cgImageForChooser = context.createCGImage(ciImageForImageChooser, from: extent) else {
            fatalError("Could not create built in image from ciContext")
        }
        let imageForChooser = UIImage(cgImage: cgImageForChooser)
        self.imageForImageChooser = imageForChooser
    }
}
