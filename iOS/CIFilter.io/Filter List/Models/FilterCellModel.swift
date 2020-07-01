//
//  FilterCellModel.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/29/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import ReactiveLists
import SwiftUI

extension TableCellViewModel where Self: View {
    var registrationInfo: ViewRegistrationInfo {
        return ViewRegistrationInfo(classType: HostingCell<Self>.self)
    }

    var cellIdentifier: String {
        return String(describing: HostingCell<Self>.self)
    }

    var rowHeight: CGFloat {
        return UITableView.automaticDimension
    }

    func applyViewModelToCell(_ cell: UITableViewCell) {
        guard let cell = cell as? HostingCell<Self> else { return }
        cell.rootView = self
    }
}

struct FilterCellModel: TableCellViewModel, DiffableViewModel, View {
//    var registrationInfo = ViewRegistrationInfo(classType: HostingCell<FilterListNameView>.self)
    var accessibilityFormat: CellAccessibilityFormat = "FilterListNameCell"
//    let cellIdentifier = "FilterListNameCell"
//    let rowHeight: CGFloat = UITableView.automaticDimension

    let filter: CIFilter
    let didSelect: DidSelectClosure?
    let didSelectJumpToWorkshop: DidSelectClosure?

//    init(filter: CIFilter, didSelect: @escaping DidSelectClosure, didSelectJumpToWorkshop: @escaping DidSelectClosure) {
//        self.filter = filter
//        self.didSelect = didSelect
//        self.didSelectJumpToWorkshop = didSelectJumpToWorkshop
//    }

//    func applyViewModelToCell(_ cell: UITableViewCell) {
//        guard let cell = cell as? HostingCell<FilterListNameView> else { return }
//        cell.rootView = FilterListNameView(name: self.filter.name, description: self.filter.description)
////        cell.set(text: "\(self.filter.name)")
//    }

    var diffingKey: String {
        return self.filter.name
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Rectangle()
                .fill(Color(.opaqueSeparator))
                .frame(width: 2)
            Text(self.filter.name).foregroundColor(Color(.secondaryLabel))
                .padding([.top, .bottom], 10)
            Spacer()
        }.padding([.leading, .trailing], 10)
    }
}
