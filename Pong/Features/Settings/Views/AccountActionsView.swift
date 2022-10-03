import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct AccountActionsView: View {
    @StateObject private var settingsVM = SettingsViewModel()
    
    var body: some View {
        List {
            
            Section("ACTIONS") {
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
                
                Divider()
                
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
                
                
                HStack {
                    Spacer()
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        settingsVM.activeAlertType = .signOut
                        settingsVM.activeAlert = true
                    } label: {
                        Text("Logout")
                            .frame(minWidth: 75, maxWidth: 100)
                            .font(.system(size: 18).bold())
                            .padding()
                            .background(Color(UIColor.label))
                            .foregroundColor(Color("pongSystemBackground"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color(UIColor.label), lineWidth: 2)
                            )
                    }
                    .background(Color(UIColor.label)) // If you have this
                    .cornerRadius(50)         // You also need the cornerRadius here
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 30)
                    Spacer()
                }
            }
            .listRowBackground(Color("pongSystemBackground"))
            .listRowSeparator(.hidden)
            
        }
        .environment(\.defaultMinListRowHeight, 0)
        .background(Color("pongSystemBackground"))
        .listStyle(PlainListStyle())
        .frame(maxWidth: .infinity)
        .navigationTitle("Account Actions")
        .navigationBarTitleDisplayMode(.inline)
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


