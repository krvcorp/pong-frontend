//
//  AccountsSheetView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import SwiftUI

struct AccountsSheetView: View {
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
//                            BackButton()
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Text("Account")
                        .font(.title.bold())
                }
                // BODY
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(AccountsSheetEnum.allCases, id: \.rawValue) { accountSheetEnum in
                        switch accountSheetEnum {
                        case .deleteAccount:
                            AccountsOptionRowView(accountsSheetEnum: accountSheetEnum)
                                .onTapGesture {
                                    print("DEBUG: AccountSheetView Button click delete account")
                                    settingsSheetVM.showAccountSheetView.toggle()
                                    settingsSheetVM.showDeleteAccountConfirmationView.toggle()
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

struct AccountsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsSheetView(settingsSheetVM: SettingsSheetViewModel())
    }
}
