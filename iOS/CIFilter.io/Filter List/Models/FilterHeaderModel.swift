//
//  FilterHeaderModel.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/29/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import ReactiveLists

final class FilterHeaderModel: TableSectionHeaderFooterViewModel {
    let title: String?
    let height: CGFloat? = UITableView.automaticDimension
    let viewInfo: SupplementaryViewInfo?

    init(filterName: String) {
        title = filterName
        viewInfo = SupplementaryViewInfo(
            registrationInfo: ViewRegistrationInfo(classType: FilterCategoryHeaderView.self),
            kind: .header,
            accessibilityFormat: "FilterCategoryHeaderView"
        )
    }

    func applyViewModelToView(_ view: UIView) {
        (view as? FilterCategoryHeaderView)?.label.text = title
    }
}
