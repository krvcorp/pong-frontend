
import Foundation

struct LoggedInUserInfoResponseBody: Decodable {
    let id: String
    let email: String?
    let posts: [Post]
    let comments: [Comment]
    let inTimeout: Bool
    let phone: String
    let commentKarma: Int
    let postKarma: Int
    let totalKarma: Int
    let savedPosts: [Post]
}
