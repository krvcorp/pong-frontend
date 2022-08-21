import Foundation

struct User: Identifiable, Codable {
    var id: String
    var posts: [Post]
    var comments: [Comment]
    var inTimeout: Bool
    var commentScore: Int
    var postScore: Int
    var totalScore: Int
    var upvotedPosts: [Post]
    var savedPosts: [Post]
}

