import Foundation

struct CreateConversation {
    struct RequestPost: Encodable {
        let postId: String
    }
    
    struct RequestComment: Encodable {
        let commentId: String
    }
    
    struct Response: Decodable {
        let id: String
        let messages: [String]
        let re: String
    }
}
