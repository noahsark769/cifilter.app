//
//  FilterDetailExampleHeaderView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/8/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

final class FilterDetailExampleHeaderView: UIView {
    private var tryHandler: (() -> Void)? = nil
    private let exampleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.boldSystemFont(ofSize: 14)
        view.textColor = UIColor(rgb: 0xF5BD5D)
        view.text = "EXAMPLE"
        return view
    }()

    private lazy var tryItButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setAttributedTitle(
            NSAttributedString(
                string: "Try it!",
                attributes: [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14),
                    NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x80a5b1),
                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
                ]
            ),
            for: .normal
        )
        view.setTitleColor(UIColor(rgb: 0x80a5b1), for: .normal)
        view.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return view
    }()

    init() {
        super.init(frame: .zero)

        addSubview(exampleLabel)
        addSubview(tryItButton)

        [exampleLabel, tryItButton].disableTranslatesAutoresizingMaskIntoConstraints()

        tryItButton.topAnchor <=> self.topAnchor
        tryItButton.bottomAnchor <=> self.bottomAnchor
        tryItButton.trailingAnchor <=> self.trailingAnchor
        exampleLabel.leadingAnchor <=> self.leadingAnchor
        tryItButton.centerYAnchor <=> exampleLabel.centerYAnchor
    }

    func set(tryHandler: @escaping () -> Void) {
        self.tryHandler = tryHandler
    }

    @objc private func buttonTapped(_ sender: UIControl) {
        self.tryHandler?()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
