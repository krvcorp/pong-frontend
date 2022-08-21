
import Foundation

struct LoggedInUserInfoResponseBody: Decodable {
    var id: String
    var inTimeout: Bool
    var commentScore: Int
    var postScore: Int
    var totalScore: Int
    var isSuperuser: Bool
}
