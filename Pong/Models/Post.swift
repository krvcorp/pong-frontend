import Foundation

struct Post: Hashable, Codable, Identifiable, Equatable {
    var id: String
    var title: String
    var createdAt: String
    var updatedAt: String
    var image: String?
    var numComments: Int
    var score: Int
    var timeSincePosted: String
    var voteStatus: Int
    var saved: Bool
    var flagged: Bool
    var blocked: Bool
    var numUpvotes: Int
    var numDownvotes: Int
    var userOwned: Bool
    var poll: Poll?
}

