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
    private let separator = SeparatorView(color: UIColor(rgb: 0xdddddd))

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        // https://stackoverflow.com/questions/15604900/uitableviewheaderfooterview-unable-to-change-background-color
        self.backgroundView = UIView(frame: self.bounds)
        self.backgroundView?.backgroundColor = .systemBackground

        self.position = .header
        label.font = .boldSystemFont(ofSize: 22)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.disableTranslatesAutoresizingMaskIntoConstraints()

        self.contentView.addSubview(label)
        self.contentView.addSubview(separator)

        // One each of the left and bottom constraints have to be 999 priority in order to avoid
        // pesky autolayout encapsulated height issues
        // http://aplus.rs/2017/one-solution-for-90pct-auto-layout/
        label.bottomAnchor <=> self.contentView.bottomAnchor -- 10
        let top = label.topAnchor.constraint(equalTo: self.contentView.topAnchor)
        top.priority = UILayoutPriority(rawValue: 999)
        top.constant = 20
        top.isActive = true
        let leading = label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor)
        leading.priority = UILayoutPriority(rawValue: 1000)
        leading.constant = 10
        leading.isActive = true
        let trailing = label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        trailing.priority = UILayoutPriority(rawValue: 999)
        trailing.constant = -5
        trailing.isActive = true

        separator |= self.contentView
        separator =| self.contentView
        separator.bottomAnchor <=> self.contentView.bottomAnchor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
