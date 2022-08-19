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
        let lblist = leaderboardVM.leaderboardList
        NavigationView {
            VStack {
                VStack {
                    List {
                        karmaInfo
                            .padding([.leading, .top, .trailing])
                            .listRowSeparator(.hidden)
                        
                        LeaderboardTopThree(
                            hasTopThree: [
                                lblist.count >= 1,
                                lblist.count >= 2,
                                lblist.count >= 3,
                            ],
                            topThreeScores: [
                                lblist.count >= 1 ? lblist[0].score : 0,
                                lblist.count >= 2 ? lblist[1].score : 0,
                                lblist.count >= 3 ? lblist[2].score : 0,
                            ]
                        )
                        
                        if (lblist.count > 3) {
                            Section(header: Text("Leaderboard")) {
                                ForEach(lblist) { entry in
                                    if !["1", "2", "3"].contains(entry.place) {
                                        HStack {
                                            Text("\(entry.place).")
                                            Text("\(entry.score)")
                                            Spacer()
                                        }
                                    }
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
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
            .previewInterfaceOrientation(.portrait)
    }
}

