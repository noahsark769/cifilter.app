//
//  FilterDetailSwiftUIView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 7/31/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

extension Colors: View {
    var body: some View {
        Color(uiColor: self.color)
    }
}

extension Color {
    init(rgb: Int) {
        self.init(
            red: Double((rgb >> 24) & 0xFF) / 256,
            green: Double((rgb >> 16) & 0xFF) / 256,
            blue: Double((rgb >> 8) & 0xFF) / 256,
            opacity: Double(rgb & 0xFF) / 256
        )
    }

    init(uiColor: UIColor) {
        self.init(rgb: uiColor.toHex())
    }
}

struct FilterDetailTitleSwiftUIView: View {
    let title: String
    let categories: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(Font.system(size: 46).bold())
            Text(categories.joined(separator: ", "))
                .foregroundColor(
                    Color(uiColor: ColorCompatibility.secondaryLabel)
                )
        }
    }
}

struct OptionalContent<SomeViewType: View, NoneViewType: View, OptionalType>: View {
    let value: OptionalType?

    let someContent: (OptionalType) -> SomeViewType
    let noneContent: () -> NoneViewType

    var body: ConditionalContent<SomeViewType, NoneViewType> {
        if let value = value {
            return ViewBuilder.buildEither(first: someContent(value))
        } else {
            return ViewBuilder.buildEither(second: noneContent())
        }
    }
}

struct FilterDetailSwiftUIView: View {
    let filterInfo: FilterInfo?

    var body: some View {
        OptionalContent(
            value: filterInfo,
            someContent: { filterInfo in
                FilterDetailContentView(filterInfo: filterInfo)
            }, noneContent: {
                ZStack {
                    Colors.primary
                    Text("Select a filter to view details")
                        .foregroundColor(.white)
                }
            }
        )
    }
}

#if DEBUG
struct FilterDetailSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        FilterDetailSwiftUIView(filterInfo: try! FilterInfo(filter: CIFilter.boxBlur()))
    }
}
#endif

struct FilterDetailContentView: View {
    let filterInfo: FilterInfo

    var body: some View {
        return VStack {
            FilterDetailTitleSwiftUIView(title: filterInfo.name, categories: filterInfo.categories)
            Divider()
        }
    }
}
