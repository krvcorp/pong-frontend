import Foundation

struct ProfileComment: Hashable, Identifiable, Codable {
    var id: String
    var re: String
    var rePostId: String
    var comment: String
    var score: Int
    var timeSincePosted: String
    var voteStatus: Int
    var image: String?
}
