//
//  FilterCategoryHeaderView
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/28/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import YLTableView

final class FilterCategoryHeaderView: YLTableViewSectionHeaderFooterView {
    let label = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.position = .header
        label.font = .boldSystemFont(ofSize: 22)

        self.contentView.addSubview(label)
        label.edges(to: self.contentView, insets: UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 5))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
