import Foundation

struct Comment: Hashable, Identifiable, Codable {
    var id: String
    var post: String
    var comment: String
    var createdAt: String
    var updatedAt: String
    var score: Int
    var timeSincePosted: String
    var parent: String?
    var children: [Comment]
    var numberOnPost: Int
    var userOwned: Bool
    var voteStatus: Int
    var numberReplyingTo: Int?
    var image: String?
    var imageHeight: Int?
    var imageWidth: Int?
}
