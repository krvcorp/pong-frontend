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
                    List {
                        karmaInfo
                            .padding()
                        
                        Section(header: Text("Leaderboard")) {
                            ForEach(leaderboardVM.leaderboardList) { entry in
                                if entry.place == "1" {
                                    HStack {
                                        Text("\(entry.place).")
                                        Text("\(entry.score)")
                                        Spacer()
                                    }
                                    .listRowBackground(Color.poshGold)
                                } else if entry.place == "2" {
                                    HStack {
                                        Text("\(entry.place).")
                                        Text("\(entry.score)")
                                        Spacer()
                                    }
                                    .listRowBackground(Color.silver)
                                } else if entry.place == "3" {
                                    HStack {
                                        Text("\(entry.place).")
                                        Text("\(entry.score)")
                                        Spacer()
                                    }
                                    .listRowBackground(Color.bronze)
                                } else {
                                    HStack {
                                        Text("\(entry.place).")
                                        Text("\(entry.score)")
                                        Spacer()
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
    }
}

