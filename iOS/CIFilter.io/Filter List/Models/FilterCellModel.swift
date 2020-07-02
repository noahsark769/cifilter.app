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

struct FilterCellModelView: TableCellViewModel, DiffableViewModel, View {
    var accessibilityFormat: CellAccessibilityFormat = "FilterCellModelView"

    let filter: FilterInfo
    let didSelect: DidSelectClosure?
    let didSelectJumpToWorkshop: DidSelectClosure?

    var diffingKey: String {
        return self.filter.name
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Rectangle()
                .fill(Color(.opaqueSeparator))
                .frame(width: 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(self.filter.name)
                Text(self.filter.description ?? "No description provided by CoreImage")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
                    .lineLimit(1)
            }
            .padding([.top, .bottom], 10)
            Spacer()
        }
        .padding([.leading, .trailing], 10)
        .edgesIgnoringSafeArea(.all)
    }
}
