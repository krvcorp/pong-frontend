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
    
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var displayMode = 0
    @State private var notifications = false
    
    var body: some View {
        LoadingView(isShowing: .constant(false)) {
            NavigationView {
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
                        Button(action: settingsViewModel.logout) {
                            HStack {
                                Text("Sign Out").foregroundColor(.red)
                                Spacer()
                                Image(systemName: "arrow.uturn.left").foregroundColor(.red)
                            }                        }
                        Button(action: settingsViewModel.logout) {
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
                            Picker("Display Mode", selection: $displayMode) {
                                Text("System").tag(0)
                                Text("Light").tag(1)
                                Text("Dark").tag(2)
                            }
                            .pickerStyle(.segmented)
                        }
                        Toggle("Notifications", isOn: $notifications)
                    }.modifier(ProminentHeaderModifier())
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Settings")
                .onAppear {
                    UITableView.appearance().showsVerticalScrollIndicator = false
                }
                .navigationBarTitle(Text("Settings"))
                .background(Color(UIColor.systemGroupedBackground))
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
