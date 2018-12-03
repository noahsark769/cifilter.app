//
//  FilterDetailView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/2/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import AloeStackView

final class FilterDetailView: UIView {
    private let titleView = FilterDetailTitleView()
    private let availabilityView = FilterAvailabilityView()

    private let descriptionLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }()

    private let parametersLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.boldSystemFont(ofSize: 14)
        view.textColor = UIColor(rgb: 0xF5BD5D)
        return view
    }()

    private let stackView: AloeStackView = {
        let view = AloeStackView()
        view.rowInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        view.separatorInset = UIEdgeInsets.zero
        return view
    }()

    private let parametersStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()

    init() {
        super.init(frame: .zero)

        stackView.addRow(titleView)
        stackView.setInset(forRow: titleView, inset: UIEdgeInsets(top: 100, left: 10, bottom: 10, right: 10))

        stackView.automaticallyHidesLastSeparator = true
        stackView.hidesSeparatorsByDefault = true
        stackView.addRow(availabilityView)
        stackView.addRow(descriptionLabel)
        stackView.addRow(parametersLabel)
        stackView.setInset(forRow: parametersLabel, inset: UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0))

        stackView.addRow(parametersStackView)
        stackView.setInset(forRow: parametersStackView, inset: UIEdgeInsets(top: 10, left: 0, bottom: 40, right: 0))

        addSubview(stackView)
        stackView.edgesToSuperview()
    }

    func set(filter: FilterInfo) {
        titleView.set(filter: filter)
        availabilityView.set(filter: filter)
        descriptionLabel.text = filter.description
        parametersLabel.text = filter.parameters.count > 0 ? "PARAMETERS" : "THIS FILTER TAKES NO PARAMETERS"

        parametersStackView.removeAllArrangedSubviews()
        for parameter in filter.parameters {
            let view = FilterParameterView()
            view.set(parameter: parameter, filter: filter)
            parametersStackView.addArrangedSubview(view)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
