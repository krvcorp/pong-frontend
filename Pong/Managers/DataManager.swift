import Foundation
import SwiftUI

class DataManager : ObservableObject {
    
    static let shared = DataManager()
    
    // feed
    @Published var topPosts : [Post] = []
    @Published var hotPosts : [Post] = []
    @Published var recentPosts : [Post] = []
    
    @Published var postComments : [(String, [Comment])] = []
    
    var topCurrentPage = "posts/?sort=top"
    var hotCurrentPage = "posts/?sort=hot"
    var recentCurrentPage = "posts/?sort=new"
    
    // profile
    var profileInit = false
    @Published var profilePosts : [Post] = []
    @Published var profileComments : [ProfileComment] = []
    @Published var awards : [String] = []
    @Published var profileSavedPosts : [Post] = []
    
    var profilePostsCurrentPage = "posts/?sort=profile"
    var profileCommentsCurrentPage = "comments/?sort=profile"
    var profileSavedCurrentPage = "posts/?sort=new"
    
    // leaderboard
    var leaderboardInit = false
    @Published var nickname : String = ""
    @Published var nicknameEmoji : String = "🏓"
    @Published var rank : String = "1st"
    @Published var rankBehind : String = "1st"
    @Published var karmaBehind : Int = 0
    @Published var leaderboardList : [LeaderboardUser] = []
    
    // notifications
    var notificationsInit = false
    @Published var notificationHistoryWeek: [NotificationsModel] = []
    @Published var notificationHistoryPrevious: [NotificationsModel] = []
    
    // user stats
    @Published var totalKarma : Int = 0
    @Published var commentKarma : Int = 0
    @Published var postKarma : Int = 0
    @Published var numberReferred : Int = 0
    
    // messaging
    @Published var conversations : [Conversation] = []
    var timePassed = 0
    var timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    // error on startup
    @Published var errorDetected = false
    @Published var isAppLoading = true
    
    // MARK: LoadStartupState
    func loadStartupState() {
        self.initHotPosts()
        self.getConversations()
//        self.initTopPosts()
//        self.initRecentPosts()
//        self.initLeaderboard()
//        self.initNotifications()
//        self.initProfile()
    }
    
    // MARK: InitTopPosts
    func initTopPosts() {
        let selectedFeedFilter : FeedFilter = .top
        initSelectionPosts(selectedFeedFilter: selectedFeedFilter)
    }
    
    // MARK: InitHotPosts
    func initHotPosts() {
        let selectedFeedFilter : FeedFilter = .hot
        initSelectionPosts(selectedFeedFilter: selectedFeedFilter)
    }
    
    // MARK: InitRecentPosts
    func initRecentPosts() {
        let selectedFeedFilter : FeedFilter = .recent
        initSelectionPosts(selectedFeedFilter: selectedFeedFilter)
    }
    
    // MARK: InitSelectionPosts
    func initSelectionPosts(selectedFeedFilter : FeedFilter) {
        var url_to_use = ""
        
        if selectedFeedFilter == .top {
            url_to_use = "posts/?sort=top"
        } else if selectedFeedFilter == .hot {
            url_to_use = "posts/?sort=hot"
        } else if selectedFeedFilter == .recent {
            url_to_use = "posts/?sort=new"
        }
        
        NetworkManager.networkManager.request(route: url_to_use, method: .get, successType: PaginatePostsModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    if selectedFeedFilter == .top {
                        self.topPosts = successResponse.results
                        if let nextLink = successResponse.next {
                            self.topCurrentPage = nextLink
                        }
                    } else if selectedFeedFilter == .hot {
                        self.hotPosts = successResponse.results
                        withAnimation {
                            self.isAppLoading = false
                        }
                        if let nextLink = successResponse.next {
                            self.hotCurrentPage = nextLink
                        }
                    } else if selectedFeedFilter == .recent {
                        self.recentPosts = successResponse.results
                        if let nextLink = successResponse.next {
                            self.recentCurrentPage = nextLink
                        }
                    }
                }
            }
            
            if errorResponse != nil {
                self.errorDetected = true
            }
        }
    }
    
    // MARK: InitLeaderboard
    func initLeaderboard() {
        NetworkManager.networkManager.request(route: "users/leaderboard/", method: .get, successType: LeaderboardInfo.self) { successResponse, errorResponse in
            DispatchQueue.main.async {
                if let successResponse = successResponse {
                    var leaderboardList = successResponse.users
                    
                    var count : Int = 1
                    for _ in leaderboardList {
                        leaderboardList[count-1].place = String(count)
                        count += 1
                    }
                    self.leaderboardList = leaderboardList
                    self.karmaBehind = successResponse.karmaBehind
                    self.rank = successResponse.rank
                    self.rankBehind = successResponse.rankBehind
                    self.nicknameEmoji = successResponse.nicknameEmoji
                    self.nickname = successResponse.nickname
                    self.totalKarma = successResponse.score
                }
                self.leaderboardInit = true
            }
        }
    }
    
    // MARK: InitProfile
    func initProfile() {
        self.initProfilePosts()
        self.initProfileComments()
        self.initAwards()
        self.initProfileSavedPosts()
        self.initUserInformation()
    }
    
    // MARK: InitProfilePosts
    func initProfilePosts() {
        NetworkManager.networkManager.request(route: "posts/?sort=profile", method: .get, successType: PaginatePostsModel.Response.self) { successResponse, errorResponse in
            DispatchQueue.main.async {
                if let successResponse = successResponse {
                    self.profilePosts = successResponse.results
                    let uniqued = self.profilePosts.uniqued()
                    self.profilePosts = uniqued
                    if let nextLink = successResponse.next {
                        self.profilePostsCurrentPage = nextLink
                    }
                }
                
                self.profileInit = true
            }
        }
    }
    
    // MARK: InitProfileComments
    func initProfileComments() {
        NetworkManager.networkManager.request(route: "comments/?sort=profile", method: .get, successType: PaginateProfileCommentsModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    self.profileComments = successResponse.results
                    let uniqued = self.profileComments.uniqued()
                    self.profileComments = uniqued
                    if let nextLink = successResponse.next {
                        self.profileCommentsCurrentPage = nextLink
                    }
                }
            }
        }
    }
    
    // MARK: InitAwards
    func initAwards() {
        
    }
    
    // MARK: InitProfileSavedPosts
    func initProfileSavedPosts() {
        NetworkManager.networkManager.request(route: "posts/?sort=saved", method: .get, successType: PaginatePostsModel.Response.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    self.profileSavedPosts = successResponse.results
                    if let nextLink = successResponse.next {
                        self.profileSavedCurrentPage = nextLink
                    }
                }
            }
        }
    }
    
    // MARK: InitUserInformation
    func initUserInformation() {
        NetworkManager.networkManager.request(route: "users/\(AuthManager.authManager.userId)/", method: .get, successType: User.self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    self.totalKarma = successResponse.score
                    self.commentKarma = successResponse.commentScore
                    self.postKarma = successResponse.postScore
                    self.nickname = successResponse.nickname
                    self.numberReferred = successResponse.numberReferred
                }
            }
        }
    }
    
    // MARK: Helper function to delete posts
    func removePostLocally(post: Post, message: String) {
        DispatchQueue.main.async {
            withAnimation {
                if let index = self.topPosts.firstIndex(where: {$0.id == post.id}) {
                    self.topPosts.remove(at: index)
                }
                if let index = self.hotPosts.firstIndex(where: {$0.id == post.id}) {
                    self.hotPosts.remove(at: index)
                }
                if let index = self.recentPosts.firstIndex(where: {$0.id == post.id}) {
                    self.recentPosts.remove(at: index)
                }
                if let index = self.profilePosts.firstIndex(where: {$0.id == post.id}) {
                    self.profilePosts.remove(at: index)
                }
                if let index = self.profileSavedPosts.firstIndex(where: {$0.id == post.id}) {
                    self.profileSavedPosts.remove(at: index)
                }
                print("DEBUG: \(message)")
                ToastManager.shared.toastDetected(message: message)
            }
        }
    }
    
    // MARK: RemoveCommentLocally
    func removeCommentLocally(commentId: String, message: String) {
        DispatchQueue.main.async {
            withAnimation {
                if let index = self.profileComments.firstIndex(where: {$0.id == commentId}) {
                    self.profileComments.remove(at: index)
                    ToastManager.shared.toastDetected(message: message)
                }
            }
        }
    }
    
    // MARK: Update post locally
    func updatePostLocally(post: Post) {
        DispatchQueue.main.async {
            if let index = self.topPosts.firstIndex(where: {$0.id == post.id}) {
                self.topPosts[index] = post
            }
            if let index = self.hotPosts.firstIndex(where: {$0.id == post.id}) {
                self.hotPosts[index] = post
            }
            if let index = self.recentPosts.firstIndex(where: {$0.id == post.id}) {
                self.recentPosts[index] = post
            }
            if let index = self.profilePosts.firstIndex(where: {$0.id == post.id}) {
                self.profilePosts[index] = post
            }
            if let index = self.profileSavedPosts.firstIndex(where: {$0.id == post.id}) {
                self.profileSavedPosts[index] = post
            }
        }
    }
    
    // MARK: UpdateCommentLocally
    func updateCommentLocally(comment: Comment) {
        DispatchQueue.main.async {
            if let index = self.profileComments.firstIndex(where: {$0.id == comment.id}) {
                self.profileComments[index].score = comment.score
            }
        }
    }
    
    // MARK: GetConversations
    func getConversations() {
        NetworkManager.networkManager.request(route: "conversations/", method: .get, successType: [Conversation].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    if self.conversations != successResponse {
                        self.conversations = successResponse
                    }
                }
            }
        }
    }
    
    // MARK: DeleteConversationLocally
    func deleteConversationLocally(conversationId : String) {
        DispatchQueue.main.async {
            withAnimation {
                if let index = self.conversations.firstIndex(where: {$0.id == conversationId}) {
                    self.conversations.remove(at: index)
                    ToastManager.shared.toastDetected(message: "Conversation removed!")
                }
            }
        }
    }

    // MARK: Reset
    func reset() {
        self.topPosts = []
        self.hotPosts = []
        self.recentPosts = []
        self.profilePosts = []
        self.profileComments = []
        self.profileSavedPosts = []
        self.conversations = []
        self.profilePostsCurrentPage = ""
        self.profileSavedCurrentPage = ""
        self.totalKarma = 0
        self.commentKarma = 0
        self.postKarma = 0
        self.isAppLoading = true
    }
    
    // MARK: InitNotifications
    /// Gets the notifications from within the current week timeframe
    func initNotifications() {
        NetworkManager.networkManager.request(route: "notifications/?sort=week", method: .get, successType: [NotificationsModel].self) { successResponse, errorResponse in
            DispatchQueue.main.async {
                if let successResponse = successResponse {
                    self.notificationHistoryWeek = successResponse
                }
                
                self.notificationsInit = true
            }

        }
        
        NetworkManager.networkManager.request(route: "notifications/?sort=previous", method: .get, successType: [NotificationsModel].self) { successResponse, errorResponse in
            DispatchQueue.main.async {
                if let successResponse = successResponse {
                    self.notificationHistoryPrevious = successResponse
                }
            }
        }
    }
}

