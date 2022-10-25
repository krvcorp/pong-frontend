//
//  LeaderboardTopThree.swift
//  Pong
//
//  Created by Pranav Ramesh on 8/18/22.
//

import SwiftUI

struct LeaderboardTopThree: View {
    
    var hasTopThree: [Bool]
    var topThreeScores: [Int]
    var topThreeNicknames: [String]
    
    var body: some View {
        ZStack(alignment: .center) {
            HStack {
                Spacer()
                LeaderboardAwardCoin(score: topThreeScores[1], nickname: topThreeNicknames[1], place: hasTopThree[1] ? 2 : nil)
                Rectangle()
                    .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0))
                    .frame(width: 48)
                LeaderboardAwardCoin(score: topThreeScores[2], nickname: topThreeNicknames[2], place: hasTopThree[2] ? 3 : nil)
                Spacer()
            }
            HStack {
                Spacer()
                LeaderboardAwardCoin(score: topThreeScores[0], nickname: topThreeNicknames[0], place: hasTopThree[0] ? 1 : nil)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 48, trailing: 0))
                Spacer()
            }
        }
    }
}

struct LeaderboardTopThree_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardTopThree(hasTopThree: [true, true, true], topThreeScores: [9012, 5678, 1234], topThreeNicknames: ["apple", "banana", "cow"])
            .previewInterfaceOrientation(.portrait)
    }
}
