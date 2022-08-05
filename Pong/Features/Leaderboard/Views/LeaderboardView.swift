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
    @State private var newPost = false
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    karmaInfo
                        .padding()
                    
                    List {
                        Section(header: Text("Leaderboard")) {
                            ForEach(leaderboardVM.leaderboardList) { entry in
                                HStack {
                                    Text("\(entry.place).")
                                    Text("\(entry.score)")
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                .onAppear {
                    leaderboardVM.getLeaderboard()
                    leaderboardVM.getLoggedInUserInfo()
                }
            }
            .navigationTitle("Stats")
        }
    }
    
    var karmaInfo: some View {
        ZStack {
            HStack {
                VStack(alignment: .center) {
                    Text(String(leaderboardVM.totalKarma))
                    Text("Total Karma")
                        .font(.system(size: 10.0))
                }
                Spacer()
            }

            VStack(alignment: .center) {
                Text(String(leaderboardVM.postKarma))
                Text("Post Karma")
                    .font(.system(size: 10.0))
            }
            
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    Text(String(leaderboardVM.commentKarma))
                    Text("Comment Karma")
                        .font(.system(size: 10.0))
                }
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}

