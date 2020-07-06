//
//  FilterDetailView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 12/2/18.
//  Copyright © 2018 Noah Gilmore. All rights reserved.
//

import UIKit
import Combine
import SwiftUI

struct NoExampleAvailable: View {
    let exampleState: FilterExampleState

    var body: some View {
        if case .notAvailable(let reason, let associatedLink) = exampleState {
            return VStack(alignment: .leading, spacing: 10) {
                Text("No example is available for this filter: \(reason) You can help by contributing to CIFilter.io on GitHub.")
                HStack {
                    if associatedLink != nil {
                        Button("Learn more") {
                            UIApplication.shared.open(associatedLink!, options: [:], completionHandler: nil)
                        }
                        Spacer()
                    }
                    Button("View on GitHub") {
                        UIApplication.shared.open(URL(string: "https://github.com/noahsark769/CIFilter.io")!, options: [:], completionHandler: nil)
                    }
                }
            }.padding(6).erase()
        } else {
            return EmptyView().erase()
        }
    }
}
