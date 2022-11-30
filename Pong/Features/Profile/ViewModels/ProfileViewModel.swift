import Foundation

enum ProfileFilter: String, CaseIterable, Identifiable {
    case posts, comments, saved, about
    var id: Self { self }
    
    var title: String {
        switch self {
        case .posts: return "POSTS"
        case .comments: return "COMMENTS"
        case .saved: return "SAVED"
        case .about: return "ABOUT"
        }
    }
}

class ProfileViewModel: ObservableObject {

    func getProfile(dataManager: DataManager) {
        paginatePosts(dataManager: dataManager)
        paginateSaved(dataManager: dataManager)
        getAwards(dataManager: dataManager)
        paginateComments(dataManager: dataManager)
    }
    
    func paginatePostsIfNeeded(post: Post, selectedProfileFilter: ProfileFilter, dataManager: DataManager) {
        let offsetBy = -15

        if selectedProfileFilter == .posts {
            let thresholdIndex = dataManager.profilePosts.index(dataManager.profilePosts.endIndex, offsetBy: offsetBy)
            if dataManager.profilePosts.firstIndex(where: { $0.id == post.id }) == thresholdIndex {
                paginatePosts(dataManager: dataManager)
            }
        } else if selectedProfileFilter == .saved {
            let thresholdIndex = dataManager.profileSavedPosts.index(dataManager.profileSavedPosts.endIndex, offsetBy: offsetBy)
            if dataManager.profileSavedPosts.firstIndex(where: { $0.id == post.id }) == thresholdIndex {
                paginateSaved(dataManager: dataManager)
            }
        }
    }
    
    func paginateCommentsIfNeeded(comment: ProfileComment, dataManager: DataManager) {
        let offsetBy = -15
        
        let thresholdIndex = dataManager.profileComments.index(dataManager.profileComments.endIndex, offsetBy: offsetBy)
        if dataManager.profileComments.firstIndex(where: { $0.id == comment.id }) == thresholdIndex {
            paginateComments(dataManager: dataManager)
        }
    }
    
    func paginatePosts(dataManager : DataManager) {
        NetworkManager.networkManager.request(route: dataManager.profilePostsCurrentPage, method: .get, successType: PaginatePostsModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    dataManager.profilePosts.append(contentsOf: successResponse.results)
                    let uniqued = dataManager.profilePosts.uniqued()
                    dataManager.profilePosts = uniqued
                    if let nextLink = successResponse.next {
                        dataManager.profilePostsCurrentPage = nextLink
                    }
                }
            }
        }
    }
    
    func paginateComments(dataManager : DataManager) {
        NetworkManager.networkManager.request(route: dataManager.profileCommentsCurrentPage, method: .get, successType: PaginateProfileCommentsModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    dataManager.profileComments.append(contentsOf: successResponse.results)
                    let uniqued = dataManager.profileComments.uniqued()
                    dataManager.profileComments = uniqued
                    if let nextLink = successResponse.next {
                        dataManager.profileCommentsCurrentPage = nextLink
                    }
                }
            }
        }
    }
    
    func getAwards(dataManager : DataManager) {
        print("DEBUG: Get Awards")
    }
    
    func paginateSaved(dataManager : DataManager) {
        NetworkManager.networkManager.request(route: dataManager.profileSavedCurrentPage, method: .get, successType: PaginatePostsModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    dataManager.profileSavedPosts.append(contentsOf: successResponse.results)
                    let uniqued = dataManager.profileSavedPosts.uniqued()
                    dataManager.profileSavedPosts = uniqued
                    if let nextLink = successResponse.next {
                        dataManager.profileSavedCurrentPage = nextLink
                    }
                }
            }
        }
    }
    
    func triggerRefresh(tab: ProfileFilter, dataManager: DataManager) {
        if tab == .posts {
            dataManager.initProfilePosts()
        } else if tab == .comments {
            dataManager.initProfileComments()
        } else if tab == .saved {
            dataManager.initProfileSavedPosts()
        } else if tab == .about {
            dataManager.initUserInformation()
        }
    }
}
