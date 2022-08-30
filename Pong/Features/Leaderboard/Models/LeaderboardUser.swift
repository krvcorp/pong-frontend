import Foundation

struct LeaderboardUser: Codable, Identifiable {
    var score: Int
    var place: String
    var nickname: String
    let id = UUID().uuidString
//    https://stackoverflow.com/questions/63836473/how-to-iterate-over-a-list-of-objects-that-do-not-have-an-id-property
    
    enum CodingKeys: CodingKey {
        case score
        case place
        case nickname
    }
}
