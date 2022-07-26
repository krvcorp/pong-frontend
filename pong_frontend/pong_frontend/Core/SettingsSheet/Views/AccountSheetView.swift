//
//  AccountSheetView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import SwiftUI

struct AccountSheetView: View {
    @ObservedObject var settingsSheetVM: SettingsSheetViewModel
    
    var body: some View {
        ActionSheetView(bgColor: Color(UIColor.secondarySystemBackground)) {
            VStack {
                // HEADER
                ZStack {
                    HStack() {
                        Button {
                            print("DEBUG: ActionSheetView Back")
                            settingsSheetVM.showSettingsSheetView = true
                            settingsSheetVM.showAccountSheetView = false
                        } label: {
                            BackButton()
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Text("Account")
                        .font(.title.bold())
                }
                // BODY
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(AccountSheetEnum.allCases, id: \.rawValue) { accountSheetEnum in
                        switch accountSheetEnum {
                        case .changeEmail:
                            AccountOptionRowView(accountSheetEnum: accountSheetEnum)
                                .onTapGesture {
                                    print("DEBUG: AccountSheetView Button click change email")
                                }
                        case .changePhone:
                            AccountOptionRowView(accountSheetEnum: accountSheetEnum)
                                .onTapGesture {
                                    print("DEBUG: AccountSheetView Button click change phone")
                                }
                        case .deleteAccount:
                            AccountOptionRowView(accountSheetEnum: accountSheetEnum)
                                .onTapGesture {
                                    print("DEBUG: AccountSheetView Button click delete account")
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

struct AccountSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSheetView(settingsSheetVM: SettingsSheetViewModel())
    }
}
