import Foundation

enum ProfileFilterViewModel: Int, CaseIterable {
    case posts
    case saved
    
    var title: String {
        switch self {
        case .posts: return "Posts"
        case .saved: return "Saved"
        }
    }
}

