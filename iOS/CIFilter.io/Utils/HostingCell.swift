//
//  HostingCell.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 7/1/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

final class HostingCell<Content: View>: UITableViewCell {
    private let hostingView: HostingView<Content?> = HostingView(rootView: nil)

    var rootView: Content? {
        get { hostingView.rootView }
        set { hostingView.rootView = newValue }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)


        self.contentView.addSubview(hostingView)
        hostingView.edgesToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
