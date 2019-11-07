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

    init() {
        super.init(frame: .zero)

        addSubview(stackView)
        [stackView].disableTranslatesAutoresizingMaskIntoConstraints()

        titleLabel.font = UIFont.boldSystemFont(ofSize: 46)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.2
        titleLabel.baselineAdjustment = .alignCenters
        categoriesLabel.textColor = ColorCompatibility.secondaryLabel
        categoriesLabel.numberOfLines = 0

        stackView.edgesToSuperview()
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
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
