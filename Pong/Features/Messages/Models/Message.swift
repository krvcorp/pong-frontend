import Foundation

struct Message: Hashable, Codable, Equatable {
    var id : String
    var message: String
    var createdAt: String
    var userOwned: Bool
    
    struct Request: Encodable {
        var conversationId : String
        var message : String
    }
}
