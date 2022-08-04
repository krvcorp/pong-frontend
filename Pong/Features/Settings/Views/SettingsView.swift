//
//  SettingsView.swift
//  Pong
//
//  Created by Artemas on 8/4/22.
//

import SwiftUI
import Firebase

struct SettingsView: View {
    
    @StateObject private var settingsViewModel = SettingsViewModel()
    
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
                        HStack {
                            Text("Email")
                            Spacer()
                            Text("placeholder email")
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Text("Token ID")
                            Spacer()
                            Text("placeholder token")
                                .foregroundColor(.gray)
                        }
                        Button(action: settingsViewModel.logout) {
                            Text("Sign Out")
                        }
                    }.modifier(ProminentHeaderModifier())
                    #if DEBUG
                    Section(header: Text("Debug").foregroundColor(.gray)) {
                        Toggle("Staging Server", isOn: $settingsViewModel.enableStagingServer)
                        Button(action: {
                            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
                            UIApplication.shared.registerForRemoteNotifications()
                        }) {
                            Text("Register for APNS")
                        }
                        Button(action: {
                            Messaging.messaging().token { token, error in
                              if let error = error {
                                  UIPasteboard.general.string = "Error Fetching FCM Registration Token: \(error)"
                              } else if let token = token {
                                  UIPasteboard.general.string = token
                              }
                            }
                        }) {
                            Text("Copy FCM Token")
                        }
                    }.modifier(ProminentHeaderModifier())
                    #endif
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Settings")
                .onAppear {
                    UITableView.appearance().showsVerticalScrollIndicator = false
                }
                .navigationBarTitle(Text("Settings"))
                .background(Color(UIColor.secondarySystemBackground))
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
