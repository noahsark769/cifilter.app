//
//  FilterDetailExampleHeaderView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/8/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import Combine

final class FilterDetailExampleHeaderView: UIView {
    private let exampleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.boldSystemFont(ofSize: 14)
        view.textColor = UIColor(rgb: 0xF5BD5D)
        view.text = "EXAMPLE"
        return view
    }()

    init() {
        super.init(frame: .zero)

        addSubview(exampleLabel)

        [exampleLabel].disableTranslatesAutoresizingMaskIntoConstraints()
        exampleLabel.leadingAnchor <=> self.leadingAnchor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
