//
//  DeleteConfirmationView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/29/22.
//

import SwiftUI

struct DeleteConfirmationView: View {
    @StateObject var postBubbleVM = PostBubbleViewModel()
    @ObservedObject var postSettingsVM : PostSettingsViewModel
    @ObservedObject var feedVM : FeedViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            
            Text("Delete post?")
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
                    postSettingsVM.showDeleteConfirmationView = false
                    
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
                        .background(Color(UIColor.lightGray)) // If you have this
                        .cornerRadius(20)         // You also need the cornerRadius here
                }
                
                Spacer()
                
                Button {
                    DispatchQueue.main.async {
                        postBubbleVM.deletePost(post: postSettingsVM.post, feedVM: feedVM) { result in
                            print("DEBUG: \(result)")
                        }
                        postSettingsVM.showDeleteConfirmationView = false
                    }
                } label: {
                    Text("Delete")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.system(size: 18).bold())
                        .padding()
                        .foregroundColor(Color(UIColor.white))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(UIColor.red), lineWidth: 2)
                        )
                        .background(Color(UIColor.red)) // If you have this
                        .cornerRadius(20)         // You also need the cornerRadius here
                }
            }
        }
        .padding(EdgeInsets(top: 37, leading: 24, bottom: 40, trailing: 24))
        .background(Color(UIColor.secondarySystemGroupedBackground).cornerRadius(20))
        .padding(.horizontal, 40)
    }
}

struct DeleteConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteConfirmationView(postSettingsVM: PostSettingsViewModel(), feedVM: FeedViewModel())
    }
}
