//
//  FilterDetailView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/2/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit

final class FilterDetailView: UIView {
    private let titleView: FilterDetailTitleView

    init() {
        titleView = FilterDetailTitleView()
        super.init(frame: .zero)
        addSubview(titleView)
        titleView.edgesToSuperview()
    }

    func set(filter: FilterInfo) {
        titleView.set(filter: filter)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
