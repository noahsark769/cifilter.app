//
//  FilterListNameView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 11/28/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import ColorCompatibility
import SwiftUI

//struct FilterListNameView: View {
//    let name: String
//    let description: String
//
//    var body: some View {
//        HStack(alignment: .center, spacing: 10) {
//            Rectangle()
//                .fill(Color(.opaqueSeparator))
//                .frame(width: 2)
//            Text(self.name).foregroundColor(Color(.secondaryLabel))
//                .padding([.top, .bottom], 10)
//            Spacer()
//        }.padding([.leading, .trailing], 10)
//    }
//}

//final class FilterListNameView: UIView {
//    private let label = UILabel()
//    private let border = UIView()
//
//    init() {
//        super.init(frame: .zero)
//
//        self.addSubview(border)
//        self.addSubview(label)
//
//        [label, border].disableTranslatesAutoresizingMaskIntoConstraints()
//
//        border.backgroundColor = ColorCompatibility.opaqueSeparator
//        label.textColor = ColorCompatibility.secondaryLabel
//        border.leadingAnchor <=> self.leadingAnchor
//        border.topAnchor <=> self.topAnchor
//        border.bottomAnchor <=> self.bottomAnchor
//        border.widthAnchor <=> 2
//
//        label.topAnchor <=> self.topAnchor ++ 10
//        label.bottomAnchor <=> self.bottomAnchor -- 10
//        label.trailingAnchor <=> self.trailingAnchor
//        border.trailingAnchor <=> label.leadingAnchor -- 10
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func set(text: String) {
//        self.label.text = text
//    }
//}
