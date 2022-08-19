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
    
    var body: some View {
        ZStack(alignment: .center) {
            HStack {
                Spacer()
                LeaderboardAwardCoin(score: topThreeScores[1], place: hasTopThree[1] ? 2 : nil)
                Rectangle()
                    .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0))
                    .frame(width: 48)
                LeaderboardAwardCoin(score: topThreeScores[2], place: hasTopThree[2] ? 3 : nil)
                Spacer()
            }
            HStack {
                Spacer()
                LeaderboardAwardCoin(score: topThreeScores[0], place: hasTopThree[0] ? 1 : nil)
                    .padding(EdgeInsets(top: 48, leading: 0, bottom: 0, trailing: 0))
                Spacer()
            }
        }
        .padding(.bottom)
    }
}

struct LeaderboardTopThree_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardTopThree(hasTopThree: [true, true, true], topThreeScores: [9012, 5678, 1234])
            .previewInterfaceOrientation(.portrait)
    }
}
