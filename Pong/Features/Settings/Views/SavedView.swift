//
//  SavedView.swift
//  Pong
//
//  Created by Khoi Nguyen on 11/13/22.
//

import SwiftUI

struct SavedView: View {
    @StateObject var dataManager = DataManager.shared
    
    var body: some View {
        List {
            // MARK: Posts
            if dataManager.profileSavedPosts != [] {
                ForEach($dataManager.profileSavedPosts, id: \.id) { $post in
                    PostBubble(post: $post)
                        .buttonStyle(PlainButtonStyle())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.pongSystemBackground)
                    
                    CustomListDivider()
                }
                .listRowInsets(EdgeInsets())
            } else {
                VStack(alignment: .center, spacing: 15) {

                    HStack(alignment: .center) {
                        Spacer()

                        Image("VoidImage")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.screenWidth / 2)

                        Spacer()
                    }
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Text("You have no saved posts")
                            .font(.title.bold())
                        Spacer()
                    }
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Text("Go save a post!")
                            .font(.caption)
                        Spacer()
                    }
                }
                .listRowBackground(Color.pongSystemBackground)
                .listRowSeparator(.hidden)
                .frame(height: UIScreen.screenHeight / 2)
            }
        }
        .scrollContentBackgroundCompat()
        .background(Color.pongSystemBackground)
        .environment(\.defaultMinListRowHeight, 0)
        .listStyle(PlainListStyle())
        .refreshable{
            ProfileViewModel().triggerRefresh(tab: ProfileFilter.saved)
            await Task.sleep(500_000_000)
        }
    }
}

struct SavedView_Previews: PreviewProvider {
    static var previews: some View {
        SavedView()
    }
}
