//
//  EitherView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/23/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

final class EitherView: UIView {
    private let views: [UIView]

    init(views: [UIView]) {
        self.views = views
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setEnabled(_ viewToEnable: UIView) {
        for knownView in views {
            if knownView == viewToEnable {
                viewToEnable.removeFromSuperview()
                addSubview(viewToEnable)
                viewToEnable.edgesToSuperview()
            } else {
                knownView.removeFromSuperview()
            }
        }
        self.setNeedsUpdateConstraints()
    }
}
