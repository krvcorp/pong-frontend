//
//  AccountOptionRowView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import SwiftUI

struct AccountsOptionRowView: View {
    let accountsSheetEnum: AccountsSheetEnum

    var body: some View {
        VStack {
            HStack(spacing: 16) {

                Image(systemName: accountsSheetEnum.imageName)
                    .foregroundColor(accountsSheetEnum != .deleteAccount ? .gray : Color(UIColor.red))

                Text(accountsSheetEnum.title)
                    .font(.subheadline.bold())
                    .foregroundColor(accountsSheetEnum != .deleteAccount ? Color(UIColor.label) : Color(UIColor.red))

                Spacer()
            }
            .frame(height: 40)
            .padding(.horizontal)

            Divider()
        }
        .background(Color(UIColor.secondarySystemBackground)) // necessary for clickable background
    }
}

struct AccountsOptionRowView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsOptionRowView(accountsSheetEnum: .deleteAccount)
    }
}
