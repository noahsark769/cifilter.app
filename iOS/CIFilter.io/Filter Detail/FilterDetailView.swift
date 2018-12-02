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
    private let titleView: FilterDetailTitleView

    private let stackView: AloeStackView = {
        let view = AloeStackView()
        view.rowInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        view.separatorInset = UIEdgeInsets.zero
        return view
    }()

    init() {
        titleView = FilterDetailTitleView()
        super.init(frame: .zero)

        stackView.addRow(titleView)

        addSubview(stackView)
        stackView.edgesToSuperview()
    }

    func set(filter: FilterInfo) {
        titleView.set(filter: filter)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
