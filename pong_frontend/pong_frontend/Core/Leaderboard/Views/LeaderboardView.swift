//
//  LeaderboardView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/6/22.
//

import SwiftUI

struct LeaderboardView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Your Karma: 201")
                    .font(.headline)
                
                VStack {
                    VStack (alignment: .leading) {
                        HStack {
                            Text("1")
                            Text("1233445")
                            Spacer()
                        }
                        HStack {
                            Text("2")
                            Text("123")
                            Spacer()
                        }
                        HStack {
                            Text("3")
                            Text("2")
                            Spacer()
                        }
                    }
                    .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.size.width - 50)
                    .font(.system(size: 18).bold())
                    .padding()
                    .foregroundColor(.black)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black, lineWidth: 10))
                }
                .background(Color.white) // If you have this
                .cornerRadius(20)         // You also need the cornerRadius here

        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Leaderboard")
                    .font(.title.bold())
            }
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
}
