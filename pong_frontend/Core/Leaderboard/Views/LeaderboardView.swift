//
//  LeaderboardView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/6/22.
//

import SwiftUI

struct LeaderboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var leaderboardVM = LeaderboardViewModel()
    @StateObject private var profileVM = ProfileViewModel()
    @State private var newPost = false
    
    var body: some View {
        VStack {
            RefreshableScrollView {
                Text("Your Karma: \(profileVM.totalKarma)")
                    .font(.headline)
                    .padding()
                
                VStack {
                    VStack (alignment: .leading) {
                        ForEach(leaderboardVM.leaderboardList) { entry in
                            HStack {
                                Text("\(entry.place).")
                                Text("\(entry.score)")
                                Spacer()
                            }
                        }
                    }
                    .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.size.width - 50)
                    .font(.system(size: 18).bold())
                    .padding()
                    .foregroundColor(Color(UIColor.label))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.tertiarySystemBackground), lineWidth: 5))
                    .background(Color(UIColor.tertiarySystemBackground)) // If you have this
                    .cornerRadius(10)         // You also need the cornerRadius here
                }
            }
            .onAppear {
                leaderboardVM.getLeaderboard()
                profileVM.getLoggedInUserInfo()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        BackButton()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Leaderboard")
                        .font(.title.bold())
                }
            }
            
            NavigationLink {
                NewPostView(newPost: $newPost)
            } label: {
                Text("Try to catch up :)")
                    .frame(width: 100, height: 100)
                    .padding()
            }
            .foregroundColor(Color(UIColor.tertiarySystemBackground))
            .background(Color(UIColor.label))
            .clipShape(Circle())
            .padding()
            .shadow(radius: 10)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}

