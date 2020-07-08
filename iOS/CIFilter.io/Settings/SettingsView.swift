//
//  SettingsView.swift
//  CIFilter.io
//
//  Created by Noah Gilmore on 8/4/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import SwiftUI
import Combine
import MessageUI

// From https://noahgilmore.com/blog/userdefaults-editor-swiftui/
extension Binding {
    init<RootType>(
        keyPath: ReferenceWritableKeyPath<RootType, Value>,
        object: RootType
    ) {
        self.init(
            get: { object[keyPath: keyPath] },
            set: { object[keyPath: keyPath] = $0}
        )
    }
}

struct UserDefaultsConfigToggleItemView: View {
    @ObservedObject var defaultsConfig = UserDefaultsConfig.shared
    let path: ReferenceWritableKeyPath<UserDefaultsConfig, Bool>
    let name: String

    var body: some View {
        HStack {
            Toggle(isOn: Binding(
                keyPath: self.path,
                object: self.defaultsConfig
            )) {
                Text(name)
            }
            Spacer()
        }
    }
}

// https://stackoverflow.com/questions/56784722/swiftui-send-email
struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    let recipients: [String]
    let completion: (Result<MFMailComposeResult, Error>) -> Void

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        let completion: (Result<MFMailComposeResult, Error>) -> Void

        init(
            isShowing: Binding<Bool>,
            completion: @escaping (Result<MFMailComposeResult, Error>) -> Void
        ) {
            self._isShowing = isShowing
            self.completion = completion
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            defer {
                self.isShowing = false
            }
            if let error = error {
                self.completion(.failure(error))
                return
            }
            self.completion(.success(result))
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(
            isShowing: $isShowing,
            completion: completion
        )
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(self.recipients)
        return vc
    }

    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: UIViewControllerRepresentableContext<MailView>
    ) {
        // do nothing
    }
}

struct SettingsView: View {
    @State private var showingFullBuildNumber = false
    @State private var isShowingMail = false
    let didTapDone = PassthroughSubject<Void, Never>()

    var debugView: some View {
        #if DEBUG
        return Section(header: Text("DEBUG").padding([.top], 20)) {
            Text("This would be a UserDefaultsConfigToggleItemView if there were any toggleable flags")
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
                        .onTapGesture {
                            self.showingFullBuildNumber = true
                        }
                }.foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding([.top], 60)
                    .padding([.bottom], 10)
                if self.showingFullBuildNumber {
                    Text("\(AppDelegate.shared.commitNumber()) - \(AppDelegate.shared.sha())")
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                }
                List {
                    Section(header: Text("LINKS").padding([.top], 20)) {
                        Button(action: {
                            UIApplication.shared.open(URL(string: "https://twitter.com/cifilterio")!)
                        }) {
                            Text("Twitter")
                        }
                        Button(action: {
                            UIApplication.shared.open(URL(string: "https://github.com/noahsark769/cifilter.io")!)
                        }) {
                            Text("Github")
                        }
                        Button(action: {
                            UIApplication.shared.open(URL(string: "https://itunes.apple.com/us/app/cifilter-io/id1457458557?mt=8")!)
                        }) {
                            Text("Rate on App Store")
                        }
                        Button(action: {
                            UIApplication.shared.open(URL(string: "https://github.com/noahsark769/cifilter.io/issues")!)
                        }) {
                            Text("Report a Bug")
                        }
                        Button(action: {
                            if MFMailComposeViewController.canSendMail() {
                                self.isShowingMail = true
                            } else {
                                UIApplication.shared.open(URL(string: "mailto:support@cifilter.io")!)
                            }
                        }) {
                            Text("Contact Support")
                        }
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
        }.sheet(isPresented: self.$isShowingMail, content: {
            MailView(isShowing: self.$isShowingMail, recipients: ["support@cifilter.io"], completion: { _ in
                // do nothing
            })
        })
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
