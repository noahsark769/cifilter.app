//
//  OutputImageNotGeneratedView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/2/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

/**
 * A view that displays a message telling the user that an image has not been generated for this
 * filter yet.
 */
final class OutputImageNotGeneratedView: UIView {
    private let label: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 30)
        view.text = "The output image will appear here once all parameters are selected."
        view.numberOfLines = 0
        view.textColor = ColorCompatibility.label
        return view
    }()

    init() {
        super.init(frame: .zero)
        self.backgroundColor = Colors.primary.color
        addSubview(label)
        label.edges(to: self, insets: UIEdgeInsets(all: 80))
        self.widthAnchor <=> ImageArtboardView.artboardSize
        self.heightAnchor <=> ImageArtboardView.artboardSize
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
