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
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        ForEach(SettingsSheetEnum.allCases, id: \.rawValue) { settingsSheetEnum in
                            switch settingsSheetEnum {
                            case .account:
                                Button {
                                    DispatchQueue.main.async {
                                        print("DEBUG: SettingsSheetView Button click account")
                                        settingsSheetVM.showAccountSheetView.toggle()
                                        settingsSheetVM.showSettingsSheetView = false
                                    }
                                } label: {
                                    SettingsOptionRowView(settingsSheetEnum: settingsSheetEnum)
                                }
                            case .preferences:
                                Button {
                                    print("DEBUG: SettingsSheetView Button click notifications")
                                    settingsSheetVM.showPreferencesSheetView.toggle()
                                    settingsSheetVM.showSettingsSheetView = false
                                } label: {
                                    SettingsOptionRowView(settingsSheetEnum: settingsSheetEnum)
                                }
                            case .legal:
                                Button {
                                    DispatchQueue.main.async {
                                        print("DEBUG: SettingsSheetView Button click legal")
                                        settingsSheetVM.showLegalSheetView.toggle()
                                        settingsSheetVM.showSettingsSheetView = false
                                    }
                                } label: {
                                    SettingsOptionRowView(settingsSheetEnum: settingsSheetEnum)
                                }
                            case .logout:
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
}

struct SettingsSheet_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSheetView(loginVM: LoginViewModel(), settingsSheetVM: SettingsSheetViewModel())
    }
}
