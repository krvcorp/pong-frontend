import Foundation

struct NotificationsModel: Decodable, Identifiable {
    var id: String { data.id }
    var notification: Notification
    struct Notification: Decodable {
        var title: String
        var body: String
    }
    var data: Data
    struct Data: Decodable {
        var id: String
        var timestamp: String
        var url: String?
        var type: NotificationType
        var read: Bool
        var timeSincePosted: String
        enum NotificationType: String, Decodable {
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
