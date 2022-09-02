import Foundation

struct PostVoteModel {
    struct Request: Encodable {
        let vote: Int
    }
    
    struct Response: Decodable {
        let voteStatus: Int
    }
}
