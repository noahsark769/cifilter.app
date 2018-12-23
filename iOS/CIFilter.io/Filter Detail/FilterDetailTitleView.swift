//
//  FilterDetailTitleView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/2/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

final class FilterDetailTitleView: UIView {
    private let titleLabel = UILabel()
    private let categoriesLabel = UILabel()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()

    var isCompressed: Bool = false {
        didSet {
            if self.isCompressed {
                self.stackView.removeArrangedSubview(titleLabel)
                titleLabel.removeFromSuperview()
            } else {
                self.stackView.addArrangedSubview(titleLabel)
            }
        }
    }

    init() {
        super.init(frame: .zero)

        addSubview(stackView)
        [stackView].disableTranslatesAutoresizingMaskIntoConstraints()

        titleLabel.font = UIFont.boldSystemFont(ofSize: 46)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.2
        categoriesLabel.textColor = UIColor(rgb: 0x989898)
        categoriesLabel.numberOfLines = 0

        stackView.edgesToSuperview()
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(categoriesLabel)
    }

    func set(filter: FilterInfo) {
        titleLabel.text = filter.name
        categoriesLabel.text = filter.categories.joined(separator: ", ")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
