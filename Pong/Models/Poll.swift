//
//  Poll.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/16/22.
//

import Foundation

struct Poll: Hashable, Codable {
    var id: String
    var userHasVoted: Bool
    var votedFor: String?
    var options: [Option]
    
    struct Option: Hashable, Codable {
        var title: String
        var numVotes: Int
        var id: String
    }
}
