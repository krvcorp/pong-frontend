//
//  DeleteAccountConfirmationView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/31/22.
//

import SwiftUI
import iPhoneNumberField

struct DeleteAccountConfirmationView: View {
    @ObservedObject var settingsSheetVM : SettingsSheetViewModel
    @State private var deleteText : String = ""
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            
            Text("Are you sure?")
                .foregroundColor(Color(UIColor.label))
                .font(.title.bold())
                .padding(.top, 12)
            
            Text("Deleting your account **CANNOT** be undone. This will delete your account, posts, and chats permanently")
                .foregroundColor(Color(UIColor.label))
                .font(.subheadline.bold())
                .opacity(0.6)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            Text("Please type in your phone number to confirm")
                .foregroundColor(Color(UIColor.label))
                .font(.subheadline.bold())
                .opacity(0.6)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            iPhoneNumberField("(000) 000-0000", text: $deleteText)
                .font(UIFont(size: 25, weight: .bold))
                .maximumDigits(10)
                .clearButtonMode(.whileEditing)
                .accentColor(Color(UIColor.label))
                .background(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.label), lineWidth: 1))
                .padding()
            
            VStack {
                Button {
                    settingsSheetVM.showDeleteAccountConfirmationView = false
                } label: {
                    Text("Cancel")
                        .frame(minWidth: 0, maxWidth: UIScreen.screenWidth / 2)
                        .font(.system(.body).bold())
                        .padding()
                        .foregroundColor(Color(UIColor.systemGroupedBackground))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(UIColor.label), lineWidth: 2))
                        .background(Color(UIColor.label)) // If you have this
                        .cornerRadius(20)         // You also need the cornerRadius here
                        .padding(.bottom)
                }
                
                if deleteText.count == 14 {
                    Button {
                        DispatchQueue.main.async {
                            print("DEBUG: DELETE ACCOUNT")
                        }
                    } label: {
                        Text("Delete")
                            .frame(minWidth: 0, maxWidth: UIScreen.screenWidth / 2)
                            .font(.system(.body).bold())
                            .padding()
                            .foregroundColor(Color(UIColor.white))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(UIColor.red), lineWidth: 2))
                            .background(Color(UIColor.red)) // If you have this
                            .cornerRadius(20)         // You also need the cornerRadius here
                    }
                } else {
                        Text("Delete")
                            .frame(minWidth: 0, maxWidth: UIScreen.screenWidth / 2)
                            .font(.system(.body).bold())
                            .padding()
                            .foregroundColor(Color(UIColor.label))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(UIColor.systemFill), lineWidth: 2))
                            .background(Color(UIColor.systemFill)) // If you have this
                            .cornerRadius(20)         // You also need the cornerRadius here
                }
            }
        }
        .padding(EdgeInsets(top: 37, leading: 12, bottom: 40, trailing: 12))
        .background(Color(UIColor.secondarySystemGroupedBackground).cornerRadius(20))
        .padding(.horizontal, 40)
    }
}

// preview being stupid
//struct DeleteAccountConfirmationView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeleteAccountConfirmationView(settingsSheetVM: SettingsSheetViewModel(), deleteText: .constant(""))
//    }
//}
