//
//  LeaderboardInfo.swift
//  Pong
//
//  Created by Khoi Nguyen on 11/15/22.
//

import Foundation

struct LeaderboardInfo: Codable {
    var users : [LeaderboardUser]
    var karmaBehind : Int
    var rank : String
    var rankBehind : String
    var nicknameEmoji : String
    var nickname : String
    var score : Int
}
