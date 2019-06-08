//
//  FilterApplicationIndicator.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/3/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

/**
 * Small view that indicates that the application of a filter is in progress.
 */
final class FilterApplicationIndicator: UIView {
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    init() {
        super.init(frame: .zero)
        self.backgroundColor = Colors.primary.color
        addSubview(activityIndicator)
        activityIndicator.edges(to: self, insets: UIEdgeInsets(all: 10))
        self.layer.borderColor = UIColor(rgb: 0xEFEFEF).cgColor
        self.layer.borderWidth = 1 / UIScreen.main.scale
        self.layer.cornerRadius = 2
        self.layer.shadowColor = Colors.borderGray.color.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 3
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        activityIndicator.startAnimating()
    }

    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}
