//
//  FilterAvailabilityView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/2/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

final class AvailableLabel: UIView {
    private let label = UILabel()
    private let system: String

    init(system: String, color: UIColor, insets: UIEdgeInsets) {
        self.system = system
        super.init(frame: .zero)

        self.backgroundColor = color
        self.label.textColor = ColorCompatibility.label
        self.label.font = UIFont.boldSystemFont(ofSize: 15)
        self.layer.cornerRadius = 8

        addSubview(label)
        label.edgesToSuperview(insets: insets)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(availabilityNumber: String) {
        label.text = "\(system): \(availabilityNumber)+"
    }
}

final class FilterAvailabilityView: UIView {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        return view
    }()

    init() {
        super.init(frame: .zero)
        addSubview(stackView)
        stackView.disableTranslatesAutoresizingMaskIntoConstraints()
        stackView.trailingAnchor <=> self.trailingAnchor
        stackView.topAnchor <=> self.topAnchor
        stackView.bottomAnchor <=> self.bottomAnchor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(filter: FilterInfo) {
        stackView.removeAllArrangedSubviews()

        let macLabel = AvailableLabel(system: "macOS", color: UIColor(rgb: 0xFF8D8D), insets: UIEdgeInsets(all: 10))
        macLabel.set(availabilityNumber: filter.availableMac)
        let iosLabel = AvailableLabel(system: "iOS", color: UIColor(rgb: 0x74AEDF), insets: UIEdgeInsets(all: 10))
        iosLabel.set(availabilityNumber: filter.availableIOS)
        stackView.addArrangedSubview(iosLabel)
        stackView.addArrangedSubview(macLabel)
    }
}
