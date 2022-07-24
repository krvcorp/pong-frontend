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
    @Binding var showSettings: Bool
    @Binding var showLegalSheetView: Bool
    
    var body: some View {
        ActionSheetView(bgColor: Color(UIColor.secondarySystemBackground)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    ForEach(SettingsViewModel.allCases, id: \.rawValue) { viewModel in
                        if viewModel == .account {
                            Button {
                                print("DEBUG: ACCOUNT")
                            } label: {
                                SettingsOptionRowView(viewModel: viewModel)
                            }
                        } else if viewModel == .legal {
                            Button {
                                print("DEBUG: NOTIFICATIONS")
                                showLegalSheetView.toggle()
                            } label: {
                                SettingsOptionRowView(viewModel: viewModel)
                            }

                        }
                        
                        else if viewModel == .logout {
                            Button {
                                print("DEBUG: SIGN OUT")

                                loginVM.signout()
                                showSettings = false
                            } label: {
                                SettingsOptionRowView(viewModel: viewModel)
                            }
                            
                        } else {
                            SettingsOptionRowView(viewModel: viewModel)
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
        SettingsSheetView(loginVM: LoginViewModel(), showSettings: .constant(true), showLegalSheetView: .constant(true))
    }
}
