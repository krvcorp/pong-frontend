//
//  SettingsView.swift
//  Pong
//
//  Created by Artemas on 8/4/22.
//

import SwiftUI
import Firebase
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var settingsVM = SettingsViewModel()
    @State private var notifications = false
    
    var body: some View {
        LoadingView(isShowing: .constant(false)) {
            List {
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Environment")
                        Spacer()
                        #if DEBUG
                            Text("Debug")
                                .foregroundColor(.gray)
                        #else
                            Text("Release")
                                .foregroundColor(.gray)
                        #endif
                    }
                }.modifier(ProminentHeaderModifier())
                Section(header: Text("Account").foregroundColor(.gray)) {
                    Button(action: {
                        UIPasteboard.general.setValue(DAKeychain.shared["userId"] ?? "Invalid",
                                    forPasteboardType: UTType.plainText.identifier)
                    }) {
                        HStack {
                            Text("User ID").foregroundColor(Color(uiColor: UIColor.label))
                            Spacer()
                            Text( DAKeychain.shared["userId"]?.prefix(16) ?? "Invalid")
                                .foregroundColor(.gray)
                        }
                    }
                    Button(action: {
                        UIPasteboard.general.setValue(DAKeychain.shared["token"] ?? "Invalid",
                                    forPasteboardType: UTType.plainText.identifier)
                    }) {
                        HStack {
                            Text("Token").foregroundColor(Color(uiColor: UIColor.label))
                            Spacer()
                            Text( DAKeychain.shared["token"]?.prefix(16) ?? "Invalid")
                                .foregroundColor(.gray)
                        }
                    }
                    Button(action: settingsVM.logout) {
                        HStack {
                            Text("Sign Out").foregroundColor(.red)
                            Spacer()
                            Image(systemName: "arrow.uturn.left").foregroundColor(.red)
                        }                        }
                    Button(action: settingsVM.logout) {
                        HStack {
                            Text("Delete Account").foregroundColor(.red).bold()
                            Spacer()
                            Image(systemName: "trash").foregroundColor(.red).font(Font.body.weight(.bold))
                        }
                    }
                }.modifier(ProminentHeaderModifier())
                Section(header: Text("Preferences").foregroundColor(.gray)) {
                    HStack(spacing: 0) {
                        Text("Theme")
                        Spacer(minLength: 20)
                        Picker("Display Mode", selection: $settingsVM.displayMode) {
                            Text("System").tag(DisplayMode.system)
                            Text("Dark").tag(DisplayMode.dark)
                            Text("Light").tag(DisplayMode.light)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: settingsVM.displayMode) { newValue in
                            settingsVM.displayMode.setAppDisplayMode()
                        }
                    }
                    Toggle("Notifications", isOn: $notifications)
                }.modifier(ProminentHeaderModifier())
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                UITableView.appearance().showsVerticalScrollIndicator = false
            }
//            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
