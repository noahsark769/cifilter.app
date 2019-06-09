//
//  OutputImageActivityIndicatorView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 1/2/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

final class OutputImageActivityIndicatorView: UIView {
    private let activityView = UIActivityIndicatorView(style: .whiteLarge)
    init() {
        super.init(frame: .zero)
        self.backgroundColor = Colors.primary.color
        addSubview(activityView)
        activityView.disableTranslatesAutoresizingMaskIntoConstraints()
        activityView.centerXAnchor <=> self.centerXAnchor
        activityView.centerYAnchor <=> self.centerYAnchor
        self.widthAnchor <=> ImageChooserView.artboardSize
        self.heightAnchor <=> ImageChooserView.artboardSize
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        activityView.startAnimating()
    }

    func stopAnimating() {
        activityView.stopAnimating()
    }
}
