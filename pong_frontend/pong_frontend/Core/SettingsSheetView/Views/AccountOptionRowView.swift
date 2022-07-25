//
//  AccountOptionRowView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import SwiftUI

struct AccountOptionRowView: View {
    let accountSheetEnum: AccountSheetEnum

    var body: some View {
        VStack {
            HStack(spacing: 16) {

                Image(systemName: accountSheetEnum.imageName)
                    .foregroundColor(.gray)

                Text(accountSheetEnum.title)
                    .font(.subheadline.bold())
                    .foregroundColor(Color(UIColor.label))
                
                Spacer()
            }
            .frame(height: 40)
            .padding(.horizontal)
            
            Divider()
        }
    }
}

struct AccountOptionRowView_Previews: PreviewProvider {
    static var previews: some View {
        AccountOptionRowView(accountSheetEnum: .deleteAccount)
    }
}
