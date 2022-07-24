import Foundation

struct CommentVoteRequestBody: Encodable {
    let comment_id: String
    let vote: Int
}
