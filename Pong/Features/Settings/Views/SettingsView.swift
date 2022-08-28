import SwiftUI
import Firebase
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var settingsVM = SettingsViewModel()
    @State private var showAlert = false
    @State private var notifications = false
    @State private var shareSheet = false
    
    var body: some View {
        List {
            Section(header: Text("The Fun Stuff")) {
                // MARK: Admin Feed View
                if (AuthManager.authManager.isAdmin) {
                    NavigationLink(destination: AdminFeedView()){
                        HStack {
                            Text("Admin Feed View").foregroundColor(Color(uiColor: UIColor.label))
                            Spacer()
                        }
                    }
                }
                
                // MARK: Contact Us
                HStack {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        EmailController().sendEmail()
                    } label: {
                        HStack{
                            Text("Contact Us")
                            Spacer()
                            Image(systemName: "envelope")
                        }
                    }
                }
                
                // MARK: Share Pong
                HStack {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        shareSheet.toggle()
                    } label: {
                        HStack{
                            Text("Share Pong")
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    .sheet(isPresented: $shareSheet) {
                        let url = URL(string: "https://www.pong.college/")
                        ShareSheet(items: [url ?? []])
                    }
                }
                
                // MARK: Referrals View
                NavigationLink(destination: AdminFeedView()){
                    HStack {
                        Text("Referrals")
                        Spacer()
                        Image(systemName: "figure.stand.line.dotted.figure.stand")
                    }
                }
                
            }.modifier(ProminentHeaderModifier())
            
            // MARK: Preferences Section
            Section(header: Text("You Pick")) {
                // MARK: Dark Mode
                HStack(spacing: 0) {
                    Text("Dark Mode")
                    Spacer(minLength: 20)
                    Picker("Display Mode", selection: $settingsVM.displayMode) {
                        Text("Auto").tag(DisplayMode.system)
                        Text("On").tag(DisplayMode.dark)
                        Text("Off").tag(DisplayMode.light)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: settingsVM.displayMode) { newValue in
                        settingsVM.displayMode.setAppDisplayMode()
                    }
                }
                
                // MARK: Notifications
                Toggle("Notifications", isOn: $notifications)
                    .onChange(of: notifications) { value in
                        settingsVM.changeNotifications(setTo: notifications)
                    }
                
                // MARK: Logout
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    AuthManager.authManager.signout()
                } label: {
                    HStack {
                        Text("Logout").foregroundColor(.red)
                        Spacer()
                        Image(systemName: "arrow.uturn.left").foregroundColor(.red)
                    }
                }
                
                // MARK: Delete Account
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showAlert.toggle()
                } label: {
                    HStack {
                        Text("Delete Account").foregroundColor(.red).bold()
                        Spacer()
                        Image(systemName: "trash").foregroundColor(.red).font(Font.body.weight(.bold))
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Delete Account"),
                        message: Text("Are you sure you want to delete your account? This is an irreversible action, and we won't be able to recover any of your data."),
                        primaryButton: .default(
                            Text("Cancel")
                        ),
                        secondaryButton: .destructive(Text("Delete")){
                            settingsVM.deleteAccount()
                        }
                    )
                }
            }.modifier(ProminentHeaderModifier())
            
            // MARK: Legal
            Section(header: Text("The Boring Stuff").foregroundColor(.gray)) {
                // MARK: Privacy Policy
                HStack() {
                    Link("Privacy Policy", destination: URL(string: "https://www.pong.college/legal")!)
                    Spacer()
                    Image(systemName: "person.fill.questionmark")
                }
                
                // MARK: Terms of SERVICE
                HStack() {
                    Link("Terms of Service", destination: URL(string: "https://www.pong.college/legal")!)
                    Spacer()
                    Image(systemName: "newspaper")
                }
            
            }.modifier(ProminentHeaderModifier())
            
            // MARK: Admin Debug Section
            #if DEBUG
            Section(header: Text("Debug")) {
                Button(action: {
                    UIPasteboard.general.string = DAKeychain.shared["userId"]
                }) {
                    Text("Copy User ID").foregroundColor(.pink)
                }
                Button(action: {
                    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
                    UIApplication.shared.registerForRemoteNotifications()
                }) {
                    Text("Register for APNS").foregroundColor(.blue)
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
                    Text("Copy FCM Token").foregroundColor(.blue)
                }
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
                        Text("Debug")
                            .foregroundColor(.gray)
                }
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
            }.modifier(ProminentHeaderModifier())
        #endif
            
            Section {
//                Text("Copyright © 2022 KRV Corp.")
//                    .font(.system(Font.TextStyle.caption2, design: .rounded))
//                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Joined \(AuthManager.authManager.dateJoined)")
                    .font(.system(Font.TextStyle.caption2, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color.gray)
            }
            .listRowBackground(Color(UIColor.secondarySystemBackground))
            .listRowSeparator(.hidden)
        }
        .listStyle(InsetGroupedListStyle())
        .onAppear {
            UITableView.appearance().showsVerticalScrollIndicator = false
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
