import Foundation

struct Conversation: Hashable, Codable, Identifiable, Equatable {
    var id: String
    var messages: [Message]
    var re: String
    var reTimeAgo: String
    var unreadCount: Int
    var postId: String?
    var timeSinceUpdated: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
