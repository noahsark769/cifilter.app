//
//  UIEdgeInsets+Utils.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/2/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    init(all: CGFloat) {
        self.init(top: all, left: all, bottom: all, right: all)
    }
}
