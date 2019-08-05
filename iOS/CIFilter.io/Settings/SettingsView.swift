//
//  SettingsView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 8/4/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import SwiftUI
import Combine

struct SettingsView: View {
    let didTapDone = PassthroughSubject<Void, Never>()

    @State var swiftUIImageChooser: Bool = UserDefaultsConfig.swiftUIImageChooser {
        didSet {
            UserDefaultsConfig.swiftUIImageChooser = swiftUIImageChooser
        }
    }

    var debugView: some View {
        #if DEBUG
        return Section(header: Text("DEBUG").padding([.top], 20)) {
            HStack {
                Toggle(isOn: $swiftUIImageChooser, label: { Text("SwiftUI Image Chooser") })
            }
        }
        #else
        return EmptyView()
        #endif
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                HStack(alignment: .lastTextBaseline) {
                    Text("CIFilter.io")
                        .font(Font.title.bold())
                    Text("v\(AppDelegate.shared.appVersion())")
                        .font(.body)
                }.foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding([.top], 60)
                    .padding([.bottom], 10)
                List {
                    Section(header: Text("LINKS").padding([.top], 20)) {
                        Button(action: {
                            UIApplication.shared.open(URL(string: "https://twitter.com/cifilterio")!)
                        }) { Text("Twitter") }
                        Button(action: {
                            UIApplication.shared.open(URL(string: "https://github.com/noahsark769/cifilter.io")!)
                        }) {
                            Text("Github") }
                        }
                    self.debugView
                }.listStyle(GroupedListStyle())
            }.background(Colors.primary)
            Button(action: { self.didTapDone.send() }) {
                Text("Done")
                    .font(Font.body.bold())
                    .foregroundColor(.white)
                    .padding([.top], 12)
                    .padding([.trailing], 14)
            }
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
