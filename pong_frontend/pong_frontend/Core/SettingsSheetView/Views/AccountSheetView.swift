//
//  AccountSheetView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import SwiftUI

struct AccountSheetView: View {
    var body: some View {
        ActionSheetView(bgColor: Color(UIColor.secondarySystemBackground)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(AccountSheetEnum.allCases, id: \.rawValue) { accountSheetEnum in
                        if accountSheetEnum == .deleteAccount {
                            Button {
                                print("DEBUG: AccountSheetView Button click delete account")
                            } label: {
                                AccountOptionRowView(accountSheetEnum: accountSheetEnum)
                            }
                        } else if accountSheetEnum == .changePhone {
                            Button {
                                print("DEBUG: AccountSheetView Button click change phone")
                            } label: {
                                AccountOptionRowView(accountSheetEnum: accountSheetEnum)
                            }
                        } else if accountSheetEnum == .changeEmail {
                            Button {
                                print("DEBUG: AccountSheetView Button click change email")
                            } label: {
                                AccountOptionRowView(accountSheetEnum: accountSheetEnum)
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
        AccountSheetView()
    }
}
