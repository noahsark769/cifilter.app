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

    init() {
        super.init(frame: .zero)

        addSubview(titleLabel)
        addSubview(categoriesLabel)

        [titleLabel, categoriesLabel].disableTranslatesAutoresizingMaskIntoConstraints()

        titleLabel.font = UIFont.boldSystemFont(ofSize: 46)
        titleLabel.numberOfLines = 1
        categoriesLabel.textColor = UIColor(rgb: 0x989898)

        titleLabel.leadingAnchor <=> self.leadingAnchor ++ 10
        titleLabel.trailingAnchor <=> self.trailingAnchor -- 10
        categoriesLabel.leadingAnchor <=> self.leadingAnchor ++ 10
        categoriesLabel.trailingAnchor <=> self.trailingAnchor -- 10
        titleLabel.topAnchor <=> self.topAnchor ++ 10
        categoriesLabel.bottomAnchor <=> self.bottomAnchor -- 10
        titleLabel.bottomAnchor <=> categoriesLabel.topAnchor -- 10

    }

    func set(filter: FilterInfo) {
        titleLabel.text = filter.name
        categoriesLabel.text = filter.categories.joined(separator: ", ")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
