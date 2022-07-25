//
//  SettingsSheetView.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/12/22.
//

import SwiftUI
import GoogleSignIn

struct SettingsSheetView: View {
    @ObservedObject var loginVM : LoginViewModel
    @ObservedObject var settingsSheetVM : SettingsSheetViewModel
    
    var body: some View {
        ActionSheetView(bgColor: Color(UIColor.secondarySystemBackground)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    ForEach(SettingsSheetEnum.allCases, id: \.rawValue) { settingsSheetEnum in
                        if settingsSheetEnum == .account {
                            Button {
                                DispatchQueue.main.async {
                                    print("DEBUG: SettingsSheetView Button click account")
                                    settingsSheetVM.showAccountSheetView.toggle()
                                    settingsSheetVM.showSettingsSheetView = false
                                }
                            } label: {
                                SettingsOptionRowView(settingsSheetEnum: settingsSheetEnum)
                            }
                        } else if settingsSheetEnum == .notifications {
                            Button {
                                print("DEBUG: SettingsSheetView Button click notifications")
                            } label: {
                                SettingsOptionRowView(settingsSheetEnum: settingsSheetEnum)
                            }
                        } else if settingsSheetEnum == .legal {
                            Button {
                                DispatchQueue.main.async {
                                    print("DEBUG: SettingsSheetView Button click legal")
                                    settingsSheetVM.showLegalSheetView.toggle()
                                    settingsSheetVM.showSettingsSheetView = false
                                }
                            } label: {
                                SettingsOptionRowView(settingsSheetEnum: settingsSheetEnum)
                            }
                        } else if settingsSheetEnum == .logout {
                            Button {
                                print("DEBUG: SIGN OUT")
                                loginVM.signout()
                                settingsSheetVM.showSettingsSheetView = false
                            } label: {
                                SettingsOptionRowView(settingsSheetEnum: settingsSheetEnum)
                            }
                            
                        }
                    }
                    Spacer()
                }
                .background(Color(UIColor.secondarySystemBackground))
                .padding(.horizontal, 20)
            }
        }
    }
}

struct SettingsSheet_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSheetView(loginVM: LoginViewModel(), settingsSheetVM: SettingsSheetViewModel())
    }
}
