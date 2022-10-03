import SwiftUI
import Firebase
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var settingsVM = SettingsViewModel()
    @State private var shareSheet = false
    @ObservedObject private var notificationsManager = NotificationsManager.notificationsManager
    
    var body: some View {
        List {
            CustomListDivider()
            Section() {
                
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
                
                // MARK: Terms of SERVICE
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
            .listRowSeparator(.hidden)
            
            CustomListDivider()

            Section() {
                // MARK: Dark Mode
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
                Toggle(isOn: $notificationsManager.notificationsPreference, label: {
                    HStack {
                        Image(systemName: "bell").font(Font.body.weight(.bold))
                            .frame(width: 20)
                        VStack {
                            HStack {
                                Text("Notifications")
                                    .bold()
                                Spacer()
                            }
                            HStack {
                                Text("Coming soon: select only certain notifications!")
                                    .font(.caption)
                                Spacer()
                            }
                        }
                    }
                })
                .frame(minHeight: 30)
                
                // MARK: Unblock All
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    settingsVM.activeAlertType = .unblockAll
                    settingsVM.activeAlert = true
                } label: {
                    HStack {
                        Image(systemName: "eye.slash").font(Font.body.weight(.bold))
                            .frame(width: 20)
                        Text("Unblock All Users")
                            .bold()
                        Spacer()
                    }
                }
                .frame(minHeight: 30)
                
                // MARK: Delete Account
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    settingsVM.activeAlertType = .deleteAccount
                    settingsVM.activeAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash").foregroundColor(.red).font(Font.body.weight(.bold))
                            .frame(width: 20)
                        Text("Delete Account").foregroundColor(.red)
                            .bold()
                        Spacer()
                    }
                }
                .frame(minHeight: 30)
            }
            .listRowSeparator(.hidden)
                    
            

            Section() {
                HStack {
                    Spacer()
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        settingsVM.activeAlertType = .signOut
                        settingsVM.activeAlert = true
                    } label: {
                        Text("Logout")
                            .frame(minWidth: 100, maxWidth: 150)
                            .font(.system(size: 18).bold())
                            .padding()
                            .background(Color(UIColor.label))
                            .foregroundColor(Color(UIColor.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color(UIColor.label), lineWidth: 2)
                            )
                    }
                    .background(Color(UIColor.label)) // If you have this
                    .cornerRadius(50)         // You also need the cornerRadius here
                    .padding(.bottom)
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .padding(.top, 100)
            }
            .listRowBackground(Color(UIColor.clear))
            .listRowSeparator(.hidden)
            
            Section {
                VStack {
                    Text("Copyright © 2022 KRV Corp.")
                        .font(.system(Font.TextStyle.caption2, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text("Joined \(DAKeychain.shared["dateJoined"] ?? "")")
                        .font(.system(Font.TextStyle.caption2, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                        .font(.system(Font.TextStyle.caption2, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .foregroundColor(Color.gray)
            }
            .listRowBackground(Color(UIColor.clear))
            .listRowSeparator(.hidden)
        }
        .environment(\.defaultMinListRowHeight, 0)
        .background(Color(UIColor.secondarySystemBackground))
        .listStyle(PlainListStyle())
        .frame(maxWidth: .infinity)
        .navigationTitle("Settings")
        .onAppear {
            UITableView.appearance().showsVerticalScrollIndicator = false
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
