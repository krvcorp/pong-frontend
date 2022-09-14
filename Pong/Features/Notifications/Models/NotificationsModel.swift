import Foundation

struct NotificationsModel: Decodable, Identifiable {
    var id: String { data.id }
    let notification: Notification
    struct Notification: Decodable {
        let title: String
        let body: String
    }
    let data: Data
    struct Data: Decodable {
        let id: String
        let timestamp: String
        let url: String?
        let type: NotificationType
        let read: Bool
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