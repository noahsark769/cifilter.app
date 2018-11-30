//
//  SeparatorView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/29/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

final class SeparatorView: UIView {
    init(color: UIColor) {
        super.init(frame: .zero)
        self.disableTranslatesAutoresizingMaskIntoConstraints()
        self.heightAnchor <=> (1 / UIScreen.main.scale)
        self.backgroundColor = color
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
