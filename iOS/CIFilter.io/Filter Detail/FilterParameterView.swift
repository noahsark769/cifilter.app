//
//  FilterParameterView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/2/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

extension FilterInfo {
    var hasLongParameterNames: Bool {
        for parameter in self.parameters {
            if parameter.name.count > 15 {
                return true
            }
        }
        return false
    }
}

final class FilterParameterView: UIView {
    private let verticalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 5
        return view
    }()

    private let horizontalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 15
        return view
    }()

    private let nameLabel = UILabel()
    private let classLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var nameLabelConstraint: NSLayoutConstraint? = nil

    init() {
        super.init(frame: .zero)
        addSubview(horizontalStackView)

        nameLabel.font = UIFont.italicSystemFont(ofSize: 17)
        nameLabel.textColor = .secondaryLabel
        nameLabel.numberOfLines = 1
        nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5

        classLabel.font = UIFont(name: "Courier New", size: 17)
        classLabel.textColor = .secondaryLabel
        classLabel.numberOfLines = 1
        classLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        classLabel.adjustsFontSizeToFitWidth = true
        classLabel.minimumScaleFactor = 0.5

        descriptionLabel.numberOfLines = 0

        verticalStackView.addArrangedSubview(nameLabel)
        verticalStackView.addArrangedSubview(classLabel)
        horizontalStackView.addArrangedSubview(verticalStackView)
        horizontalStackView.addArrangedSubview(descriptionLabel)

        horizontalStackView.edgesToSuperview()
        nameLabelConstraint = nameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3)
        nameLabelConstraint?.isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(parameter: FilterParameterInfo, filter: FilterInfo) {
        nameLabel.text = parameter.name
        classLabel.text = parameter.classType
        descriptionLabel.text = parameter.descriptionOrDefault

        self.nameLabelConstraint?.isActive = false
        if (filter.hasLongParameterNames) {
            self.nameLabelConstraint = nameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.45)
        } else {
            self.nameLabelConstraint = nameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3)
        }
        self.nameLabelConstraint?.isActive = true
    }
}
