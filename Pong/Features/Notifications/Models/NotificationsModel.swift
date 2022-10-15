import Foundation

struct NotificationsModel: Decodable, Identifiable, Equatable {
    var id: String { data.id }
    var notification: Notification
    struct Notification: Decodable, Equatable {
        var title: String
        var body: String
    }
    
    var data: Data
    
    struct Data: Decodable, Equatable {
        var id: String
        var timestamp: String
        var url: String?
        var type: NotificationType
        var read: Bool
        var timeSincePosted: String
        enum NotificationType: String, Decodable, Equatable {
            case upvote
            case comment
            case hot
            case top
            case leader
            case message
            case reply
            case violation
            case generic
        }
    }
}
