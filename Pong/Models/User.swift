import Foundation

struct User: Identifiable, Codable {
    var id: String
    var inTimeout: Bool
    var commentScore: Int
    var postScore: Int
    var score: Int
    var isSuperuser: Bool
    var nickname: String
}
