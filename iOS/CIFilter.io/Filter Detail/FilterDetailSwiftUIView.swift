//
//  FilterDetailSwiftUIView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 7/31/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import SwiftUI

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
                    Color(uiColor: .secondaryLabel)
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
    let didTapTryIt: () -> Void

    var body: some View {
        OptionalContent(
            value: filterInfo,
            someContent: { filterInfo in
                FilterDetailContentView(
                    filterInfo: filterInfo,
                    didTapTryIt: self.didTapTryIt
                )
            }, noneContent: {
                ZStack {
                    Colors.primary
                    Text("Select a filter to view details")
                        .foregroundColor(Color(.label))
                }
                .edgesIgnoringSafeArea([.top])
            }
        )
        .navigationBarTitle(Text(filterInfo?.name ?? ""), displayMode: .inline)
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
        VStack(alignment: .leading) {
            Text("\(self.parameter.name) (\(self.parameter.classType))")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.black)
                .padding(8)
                .background(Colors.primary)
                .cornerRadius(6)
                .padding([.leading], 8)
                .zIndex(1)

            HStack {
                Text(self.parameter.description ?? "No description provided by CoreImage")
                    .multilineTextAlignment(.leading)
                    .padding(16)
                    .padding(.top, 12)
                Spacer(minLength: 0)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(6)
            .offset(y: -16)
            .zIndex(0)
        }
    }
}

struct TryItButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding([.leading, .trailing], 20)
            .padding([.top, .bottom], 10)
            .frame(minWidth: 200)
            .background(Colors.primary)
            .scaleEffect(configuration.isPressed ? 0.95: 1)
            .foregroundColor(.white)
            .cornerRadius(6)
            .animation(.spring())
    }
}

struct FilterDetailContentView: View {
    let filterInfo: FilterInfo
    let didTapTryIt: () -> Void

//    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass

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
                Text(filterInfo.description ?? "No description provided by CoreImage.")
                    .padding([.bottom], 20)

                Section(header: Text("PARAMETERS").bold().foregroundColor(Colors.primary.swiftUIColor)) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(filterInfo.parameters, id: \.name) { parameter in
                            FilterParameterSwiftUIView(parameter: parameter)
                        }
                    }.padding(.top, 8)
                }

                HStack(alignment: .center) {
                    Spacer()
                    Button(action: {
                        self.didTapTryIt()
                    }, label: {
                        Text("Try It!")
                    })
                    .buttonStyle(TryItButtonStyle())
                    Spacer()
                }
            }
            .padding(10)
//            .frame(maxWidth: horizontalSizeClass == .compact ? .infinity : 600)
        }
    }
}

struct FilterDetailSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FilterDetailSwiftUIView(filterInfo: try! FilterInfo(filter: CIFilter(name: "CIDepthBlurEffect")!), didTapTryIt: { })
                .previewDevice("iPhone X")
            FilterDetailSwiftUIView(filterInfo: try! FilterInfo(filter: CIFilter(name: "CIBoxBlur")!), didTapTryIt: { })
            .previewDevice("iPad8,1")
        }
    }
}
