//
//  DeleteConfirmationView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/29/22.
//

import SwiftUI

struct ReportConfirmationView: View {
    @ObservedObject var postSettingsVM : PostSettingsViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            
            Text("Report post?")
                .foregroundColor(Color(UIColor.label))
                .font(.title.bold())
                .padding(.top, 12)
            
            Text("\(postSettingsVM.post.title)")
                .foregroundColor(Color(UIColor.label))
                .font(.system(size: 24))
                .padding(.top, 12)
            
            Text("This action cannot be undone.")
                .foregroundColor(Color(UIColor.gray))
                .font(.system(size: 16))
                .opacity(0.6)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            HStack {
                Button {
                    postSettingsVM.showReportConfirmationView = false
                } label: {
                    Text("Cancel")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.system(size: 18).bold())
                        .padding()
                        .foregroundColor(Color(UIColor.darkGray))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(UIColor.lightGray), lineWidth: 2)
                        )
                        .background(Color(UIColor.lightGray))
                        .cornerRadius(20)
                }
                
                Spacer()
                
                Button {
                    print("DEBUG: Report")
                    postSettingsVM.reportPostAlamofire()
                } label: {
                    Text("Report")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.system(size: 18).bold())
                        .padding()
                        .foregroundColor(Color(UIColor.white))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(UIColor.red), lineWidth: 2)
                        )
                        .background(Color(UIColor.red))
                        .cornerRadius(20)
                }
            }
        }
        .padding(EdgeInsets(top: 37, leading: 24, bottom: 40, trailing: 24))
        .background(Color(UIColor.secondarySystemGroupedBackground).cornerRadius(20))
        .padding(.horizontal, 40)
    }
}

struct ReportConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        ReportConfirmationView(postSettingsVM: PostSettingsViewModel())
    }
}
