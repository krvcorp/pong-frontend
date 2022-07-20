import Foundation

struct PostReport: Codable, Identifiable {
    var id: String
    var user: String
    var title: String
    var image: String?
    var createdAt: String
    var updatedAt: String
    
    var numComments: Int
    var comments: [Comment]
    var score: Int
    var timeSincePosted: String
}

