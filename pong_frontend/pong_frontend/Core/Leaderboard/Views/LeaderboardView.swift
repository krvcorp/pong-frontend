//
//  LeaderboardView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/6/22.
//

import SwiftUI

struct LeaderboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var leaderboardVM = LeaderboardViewModel()
    
    var body: some View {
        VStack {
            RefreshableScrollView {
                Text("Your Karma: 201")
                    .font(.headline)
                
                VStack {
                    VStack (alignment: .leading) {
                        ForEach(leaderboardVM.leaderboardList) { entry in
                            HStack {
                                Text("Placement")
                                Text("\(entry.totalScore)")
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
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Leaderboard")
                        .font(.title.bold())
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}

