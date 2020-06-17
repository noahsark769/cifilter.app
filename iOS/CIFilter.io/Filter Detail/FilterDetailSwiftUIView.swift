//
//  FilterDetailSwiftUIView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 7/31/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import ColorCompatibility

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
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.2)
                .padding([.bottom], 10)
            Text(categories.joined(separator: ", "))
                .foregroundColor(
                    Color(uiColor: ColorCompatibility.secondaryLabel)
                )
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

extension View {
    func erase() -> AnyView {
        return AnyView(self)
    }
}

struct OptionalContent<SomeViewType: View, NoneViewType: View, OptionalType>: View {
    let value: OptionalType?

    let someContent: (OptionalType) -> SomeViewType
    let noneContent: () -> NoneViewType

    var body: AnyView {
        if let value = value {
            return someContent(value).erase()
        } else {
            return noneContent().erase()
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
                        .foregroundColor(Color(.label))
                }
            }
        ).navigationBarTitle(Text(filterInfo?.name ?? ""), displayMode: .inline)
    }
}

struct AvailableView: View {
    enum AvailabilityType {
        case ios
        case macos

        var color: Color {
            switch self {
            case .ios: return Colors.availabilityBlue.swiftUIColor
            case .macos: return Colors.availabilityRed.swiftUIColor
            }
        }

        var title: String {
            switch self {
            case .ios: return "iOS"
            case .macos: return "macOS"
            }
        }
    }

    let text: String
    let type: AvailabilityType

    var body: some View {
        Text("\(self.type.title): \(self.text)+")
            .font(Font.system(size: 15).bold())
            .foregroundColor(.white)
            .padding(10)
            .background(self.type.color)
            .cornerRadius(8)
    }
}

struct FilterParameterSwiftUIView: View {
    static let spacing: CGFloat = 10

    let parameter: FilterParameterInfo

    var body: some View {
        HStack(spacing: Self.spacing) {
            VStack(alignment: .leading) {
                Text(self.parameter.name)
                Text(self.parameter.classType)
            }
            .frame(minWidth: 0, maxWidth: .infinity)

            VStack(alignment: .leading) {
                Text(self.parameter.description ?? "No description provided by CoreImage")
            }
                .frame(minWidth: 0, maxWidth: .infinity)

        }.frame(minWidth: 0, maxWidth: .infinity)
    }
}

struct FilterDetailContentView: View {
    let filterInfo: FilterInfo

    var body: some View {
        ScrollView([.vertical]) {
            VStack(alignment: .leading) {
                FilterDetailTitleSwiftUIView(title: filterInfo.name, categories: filterInfo.categories)
                Divider()
                HStack {
                    Spacer()
                    AvailableView(text: filterInfo.availableIOS, type: .ios)
                    AvailableView(text: filterInfo.availableMac, type: .macos)
                }.padding([.bottom], 20)
                Text(filterInfo.description ?? "No description provided by CoreImage")
                    .padding([.bottom], 20)
                Section(header: Text("PARAMETERS").bold().foregroundColor(Colors.primary.swiftUIColor)) {
                    VStack(spacing: 10) {
                        ForEach(filterInfo.parameters, id: \.name) { parameter in
                            FilterParameterSwiftUIView(parameter: parameter)
                        }
                    }
                }
            }.padding(10)
        }
    }
}
