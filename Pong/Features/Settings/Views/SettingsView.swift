import SwiftUI
import Firebase
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var settingsVM = SettingsViewModel()
    @State private var shareSheet = false
    @ObservedObject private var notificationsManager = NotificationsManager.shared
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        List {
            Section(header: HStack {
                Text("ACCOUNT")
                    .padding()

                    Spacer()
            }
            .background(Color.pongSystemBackground)
            .listRowInsets(EdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 0))
            ) {
                
                // MARK: Referrals View
                NavigationLink(destination: ReferralsView()){
                    HStack {
                        Image(systemName: "dollarsign.circle").font(Font.body.weight(.bold))
                            .frame(width: 20)
                        Text("Referrals")
                            .bold()
                        Spacer()
                    }
                }
                .frame(minHeight: 30)
                
                // MARK: Admin Feed View
                if (AuthManager.authManager.isAdmin) {
                    NavigationLink(destination: AdminFeedView()){
                        HStack {
                            Image(systemName: "flag").font(Font.body.weight(.bold))
                                .frame(width: 20)
                            Text("Admin Feed View").foregroundColor(Color(uiColor: UIColor.label))
                                .bold()
                            Spacer()
                            
                        }
                    }
                    .frame(minHeight: 30)
                    
        
                }
                
                // MARK: Account Actions View
                NavigationLink(destination: AccountActionsView()){
                    HStack {
                        Image(systemName: "person.crop.circle").font(Font.body.weight(.bold))
                            .frame(width: 20)
                        Text("Account Actions")
                            .bold()
                        Spacer()
                    }
                }
                .frame(minHeight: 30)
            }
            .listRowBackground(Color.pongSystemBackground)
            .listRowSeparator(.hidden)
            
            Section(header: HStack {
                Text("ABOUT")
                    .padding()

                    Spacer()
            }
            .background(Color.pongSystemBackground)
            .listRowInsets(EdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 0))
            ) {
                // MARK: About Us
                NavigationLink(destination: AboutUsView()){
                    HStack {
                        Image(systemName: "checkmark.shield").font(Font.body.weight(.bold))
                            .frame(width: 20)
                        Text("About Us").foregroundColor(Color(uiColor: UIColor.label))
                            .bold()
                        Spacer()
                        
                    }
                }
                .frame(minHeight: 30)
                
                // MARK: Contact Us
                HStack {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        EmailController().sendEmail()
                    } label: {
                        HStack{
                            Image(systemName: "envelope").font(Font.body.weight(.bold))
                                .frame(width: 20)
                            Text("Contact Us")
                                .bold()
                            Spacer()
                        }
                    }
                }
                .frame(minHeight: 30)
                
                // MARK: Privacy Policy
                HStack() {
                    Image(systemName: "lock.shield").font(Font.body.weight(.bold))
                        .frame(width: 20)
                    Link(destination: URL(string: "https://www.pong.blog/legal")!, label: {
                        Text("Privacy Policy")
                            .bold()
                    })
                    Spacer()
                }
                .frame(minHeight: 30)
                
                // MARK: Terms of Service
                HStack() {
                    Image(systemName: "newspaper").font(Font.body.weight(.bold))
                        .frame(width: 20)
                    Link(destination: URL(string: "https://www.pong.blog/legal")!, label: {
                        Text("Terms of Service")
                            .bold()
                    })
                    Spacer()
                }
                .frame(minHeight: 30)
            }
            .listRowBackground(Color.pongSystemBackground)
            .listRowSeparator(.hidden)
            
            Section(header: HStack {
                Text("PREFERENCES")
                    .padding()
                    .listRowBackground(Color.pongSystemBackground)
                    .listRowSeparator(.hidden)

                    Spacer()
            }
            .background(Color.pongSystemBackground)
            .listRowInsets(EdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 0))
            ) {
                
                // MARK: Dark Mode Preferences
                HStack {
                    Image(systemName: "moon").font(Font.body.weight(.bold))
                        .frame(width: 20)
                    Text("Dark Mode")
                        .bold()
                    Spacer()
                    Picker("Display Mode", selection: $settingsVM.displayMode) {
                        Text("Auto").tag(DisplayMode.system)
                        Text("On").tag(DisplayMode.dark)
                        Text("Off").tag(DisplayMode.light)
                    }
                    .frame(maxWidth: 200)
                    .pickerStyle(.segmented)
                    .onChange(of: settingsVM.displayMode) { newValue in
                        settingsVM.displayMode.setAppDisplayMode()
                    }
                }
                .frame(minHeight: 30)
                
                // MARK: Notifications
                if !notificationsManager.notificationsPreference {
                    VStack {
                        VStack {
                            HStack {
                                Image(systemName: "bell").font(Font.body.weight(.bold))
                                    .frame(width: 20)
                                
                                HStack {
                                    Button {
                                        settingsVM.openNotifications()
                                    } label: {
                                        Text("Turn On Notifications")
                                            .bold()
                                    }
                                    
                                    Spacer()
                                }
                                .frame(minHeight: 30)
                                
                                Spacer()
                            }
                            HStack {
                                Text("Your push notifications are turned off! You'll only receive notifications in-app.")
                                    .bold()
                                    .font(.caption)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                            }
                        }
                    }
                }
                
                // MARK: Register For Notifications
                #if DEBUG
                HStack {
                    Button {
                        NotificationsManager.shared.registerForNotifications(forceRegister: true)
                    } label: {
                        HStack{
                            Image(systemName: "bell").font(Font.body.weight(.bold))
                                .frame(width: 20)
                            Text("Register for FCM Token")
                                .bold()
                            Spacer()
                        }
                    }
                }
                .frame(minHeight: 30)
                #endif
            }
            .listRowBackground(Color.pongSystemBackground)
            .listRowSeparator(.hidden)
            
            Section {
                VStack {
                    Text("Joined \(DAKeychain.shared["dateJoined"] ?? "")")
                        .font(.system(Font.TextStyle.caption2, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text("© 2022 KRV Corp.")
                        .font(.system(Font.TextStyle.caption2, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                        .font(.system(Font.TextStyle.caption2, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .foregroundColor(Color.pongSecondaryText)
                .padding(.top, 10)
            }
            .background(Color.pongSystemBackground)
            .listRowBackground(Color.pongSystemBackground)
            .listRowSeparator(.hidden)
        }
        .scrollContentBackgroundCompat()
        .background(Color.pongSystemBackground)
        .environment(\.defaultMinListRowHeight, 0)
        .listStyle(GroupedListStyle())
        .frame(maxWidth: .infinity)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            UITableView.appearance().showsVerticalScrollIndicator = false
            notificationsManager.updateNotificationsPreferences()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                print("DEBUG: Active")
                notificationsManager.updateNotificationsPreferences()
            }
        }
        .alert(isPresented: $settingsVM.activeAlert) {
            switch settingsVM.activeAlertType {
            case .unblockAll:
                return Alert(
                    title: Text("Unblock All"),
                    message: Text("Are you sure you want to unblock everyone you've blocked so far? You can't reverse this action."),
                    primaryButton: .default(
                        Text("Cancel")
                    ),
                    secondaryButton: .destructive(Text("Unblock All")){
                        settingsVM.unblockAll()
                    }
                )

            case .signOut:
                return Alert(
                    title: Text("Log Out"),
                    message: Text("Are you sure you want to logout?"),
                    primaryButton: .default(
                        Text("Cancel")
                    ),
                    secondaryButton: .destructive(Text("Logout")){
                        AuthManager.authManager.signout()
                    }
                )

            case .deleteAccount:
                return Alert(
                    title: Text("Delete Account"),
                    message: Text("Are you sure you want to delete your account? This is an irreversible action, and we won't be able to recover any of your data."),
                    primaryButton: .default(
                        Text("Cancel")
                    ),
                    secondaryButton: .destructive(Text("Delete Account").bold()){
                        settingsVM.deleteAccount()
                    }
                )
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
