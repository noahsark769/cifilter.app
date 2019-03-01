//
//  ColorInputDragIndicatorView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 3/1/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

final class ColorInputDragIndicatorView: UIView {
    private let shapeLayer = CAShapeLayer()
    private let colorLayer = CAShapeLayer()

    var sideLength: CGFloat = 0 {
        didSet {
            self.generatePaths()
        }
    }

    var indicatorColor: UIColor = .black {
        didSet {
            self.generatePaths()
        }
    }

    var cornerRadius: CGFloat = 0 {
        didSet {
            self.generatePaths()
        }
    }

    var color: CGColor? {
        get { return self.colorLayer.fillColor }
        set { self.colorLayer.fillColor = newValue }
    }

    init(sideLength: CGFloat, color: UIColor) {
        super.init(frame: .zero)
        self.layer.addSublayer(shapeLayer)
        self.layer.addSublayer(colorLayer)

        shapeLayer.fillColor = color.cgColor

        self.generatePaths()

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.36
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 10
    }

    private func generateShapePath() {
        let path = CGMutablePath()

        let upperLeft = CGPoint.zero
        let upperRight = CGPoint(x: sideLength, y: 0)
        let lowerRight = CGPoint(x: sideLength, y: sideLength)
        let lowerLeft = CGPoint(x: 0, y: sideLength)
        let bottomTip = CGPoint(x: sideLength / 2, y: sideLength * 1.5)

        // upper left
        path.move(to: upperLeft.offsetX(by: cornerRadius))

        // upper right
        path.addLine(to: upperRight.offsetX(by: -cornerRadius))
        path.addArc(tangent1End: upperRight, tangent2End: upperRight.offsetY(by: cornerRadius), radius: cornerRadius)

        // lower right
        path.addLine(to: lowerRight.offsetY(by: -cornerRadius))
        path.addArc(tangent1End: lowerRight, tangent2End: lowerRight.offsetY(by: cornerRadius).offsetX(by: -cornerRadius), radius: cornerRadius)

        // bottom of point
        path.addLine(to: bottomTip)

        // lower left
        path.addLine(to: lowerLeft.offsetX(by: cornerRadius).offsetY(by: cornerRadius))
        path.addArc(tangent1End: lowerLeft, tangent2End: lowerLeft.offsetY(by: -cornerRadius), radius: cornerRadius)

        // upper left
        path.addLine(to: upperLeft.offsetY(by: cornerRadius))
        path.addArc(tangent1End: upperLeft, tangent2End: upperLeft.offsetX(by: cornerRadius), radius: cornerRadius)
        shapeLayer.path = path
    }

    private func generateColorPath() {
        let path = UIBezierPath(rect: CGRect(x: 4, y: 4, width: sideLength - 8, height: sideLength - 8)).cgPath
        colorLayer.path = path
    }

    private func generatePaths() {
        self.generateColorPath()
        self.generateShapePath()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: sideLength, height: sideLength * 1.5)
    }
}
