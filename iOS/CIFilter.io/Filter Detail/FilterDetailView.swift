//
//  FilterDetailView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/2/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import AloeStackView
import ColorCompatibility
import Combine

final class NoExampleAvailableView: UIView {
    private let textView = UITextView()
    init() {
        super.init(frame: .zero)

        addSubview(textView)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.edgesToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with exampleState: FilterExampleState) {
        switch exampleState {
        case .available:
            // TODO: this case will never be reached
            self.textView.text = "No example is available for this filter."
        case let .notAvailable(reason):
            let string = "No example is available for this filter: \(reason) You can help by contributing to CIFilter.io on github."
            let linkRange = (string as NSString).range(of: "contributing to CIFilter.io on github")
            let attributedString = NSMutableAttributedString(string: string)
            attributedString.addAttribute(.foregroundColor, value: ColorCompatibility.label, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(.link, value: URL(string: "https://github.com/noahsark769/CIFilter.io")!, range: linkRange)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: linkRange)
            attributedString.addAttribute(.foregroundColor, value: Colors.availabilityBlue.color, range: linkRange)
            attributedString.addAttribute(.underlineColor, value: Colors.availabilityBlue.color, range: linkRange)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17), range: NSRange(location: 0, length: string.count))
            self.textView.attributedText = attributedString
        }
    }
}

final class FilterDetailView: UIView {
    private let titleView = FilterDetailTitleView()
    private let availabilityView = FilterAvailabilityView()
    private let exampleProvider = FilterExampleProvider()
    private let isCompressed: Bool

    private lazy var tryItButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setAttributedTitle(
            NSAttributedString(
                string: "Try it!",
                attributes: [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20),
                    NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x80a5b1),
                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
                ]
            ),
            for: .normal
        )
        view.setTitleColor(UIColor(rgb: 0x80a5b1), for: .normal)
        return view
    }()

    private(set) lazy var didTapWorkshop: AnyPublisher<UITapGestureRecognizer, Never> = {
        return self.tryItButton.addTapHandler()
    }()

    private let descriptionLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }()

    private let noExampleView = NoExampleAvailableView()

    fileprivate let exampleView = FilterDetailExampleHeaderView()

    private let parametersLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.boldSystemFont(ofSize: 14)
        view.textColor = UIColor(rgb: 0xF5BD5D)
        return view
    }()

    private let stackView: AloeStackView = {
        let view = AloeStackView()
        view.backgroundColor = ColorCompatibility.systemBackground
        view.rowInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        view.separatorInset = UIEdgeInsets.zero
        view.backgroundColor = ColorCompatibility.systemBackground
        return view
    }()

    private let parametersStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()

    private let exampleStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 20
        return view
    }()

    init(isCompressed: Bool) {
        self.isCompressed = isCompressed
        super.init(frame: .zero)

        addSubview(stackView)
        stackView.edgesToSafeArea(of: self)

        stackView.addRow(titleView)
        stackView.setInset(forRow: titleView, inset: UIEdgeInsets(top: isCompressed ? 10 : 70, left: 0, bottom: 10, right: 0))

        stackView.automaticallyHidesLastSeparator = true
        stackView.hidesSeparatorsByDefault = true
        stackView.addRow(availabilityView)
        stackView.addRow(descriptionLabel)
        stackView.addRow(parametersLabel)
        stackView.setInset(forRow: parametersLabel, inset: UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0))

        stackView.addRow(parametersStackView)
        stackView.setInset(forRow: parametersStackView, inset: UIEdgeInsets(top: 10, left: 0, bottom: 40, right: 0))

        stackView.addRow(exampleStackView)
        stackView.setInset(forRow: exampleStackView, inset: UIEdgeInsets(top: 20, left: 0, bottom: 60, right: 0))
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

        exampleStackView.removeAllArrangedSubviews()
        exampleStackView.addArrangedSubview(exampleView)

        let exampleState = self.exampleProvider.state(forFilterName: filter.name)
        if exampleState.isAvailable {
            self.exampleStackView.addArrangedSubview(tryItButton)
        } else {
            noExampleView.configure(with: exampleState)
            self.exampleStackView.addArrangedSubview(noExampleView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
