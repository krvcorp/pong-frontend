import SwiftUI
import AlertToast

struct NotificationsView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @StateObject private var notificationsVM = NotificationsViewModel()
    @StateObject private var dataManager = DataManager.shared
    @ObservedObject private var notificationsManager = NotificationsManager.shared
    @EnvironmentObject var mainTabVM : MainTabViewModel
    
    @State private var showAlert = false
    @State var post = defaultPost
    @State var postIsLinkActive = false
    @State var leaderboardIsLinkActive = false
    @State var thisWeekShowing = true
    
    //MARK: Body
    var body: some View {
        VStack {
            NavigationLink(destination: PostView(post: $post), isActive: $postIsLinkActive) { EmptyView() }
            NavigationLink(destination: LeaderboardView(), isActive: $leaderboardIsLinkActive) { EmptyView() }
            
            // MARK: List
            List {
                // MARK: No Notifications
                if dataManager.notificationHistoryPrevious == [] && dataManager.notificationHistoryWeek == [] {
                    VStack(alignment: .center, spacing: 15) {
                        
                        HStack(alignment: .center) {
                            Spacer()
                            
                            Image("VoidImage")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: UIScreen.screenWidth / 2)
                            
                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            Text("You have no notifications")
                                .font(.title.bold())
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.pongSystemBackground)
                    .listRowSeparator(.hidden)
                    .frame(height: UIScreen.screenHeight / 2)
                }
                // MARK: Notifications
                else {
                    Section() {
                        ForEach(dataManager.notificationHistoryWeek) { notificationModel in
                            // MARK: Notifications for post/comments
                            if notificationModel.data.type == .upvote || notificationModel.data.type == .comment || notificationModel.data.type == .hot || notificationModel.data.type == .top || notificationModel.data.type == .reply {
                                
                                Button {
                                    DispatchQueue.main.async {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        notificationsVM.getPost(url: notificationModel.data.url!, id: notificationModel.id) { success in
                                            print("DEBUG: Success")
                                            post = success
                                            postIsLinkActive = true
                                            notificationsVM.markNotificationAsRead(id: notificationModel.id)
                                        }
                                    }
                                } label: {
                                    getNotificationText(notificationModel: notificationModel)
                                }
                                .listRowBackground(!notificationModel.data.read ? Color.pongAccent.opacity(0.1) : Color.pongSystemBackground)
                                .listRowSeparator(.hidden)
                                
                            }
                            // MARK: Notifications for leaderboard
                            else if notificationModel.data.type == .leader {
                                Button {
                                    DispatchQueue.main.async {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        leaderboardIsLinkActive = true
                                        notificationsVM.markNotificationAsRead(id: notificationModel.id)
                                    }
                                } label: {
                                    getNotificationText(notificationModel: notificationModel)
                                }
                                .listRowBackground(!notificationModel.data.read ? Color.pongAccent.opacity(0.1) : Color.pongSystemBackground)
                                .listRowSeparator(.hidden)
                            }
                        }
                    } header: {
                        HStack {
                            Text("This Week")
                                .fontWeight(.heavy)
                                .foregroundColor(Color.pongLabel)
                                .padding(.bottom, 4)
                            
                            Spacer()
                            
                            Button {
                                notificationsVM.markAllAsRead()
                            } label: {
                                Text("Mark All Read")
                                    .foregroundColor(Color.pongAccent)
                                    .bold()
                            }
                        }
                        .onAppear() {
                            thisWeekShowing = true
                        }
                        .onDisappear() {
                            thisWeekShowing = false
                        }
                    }
                    // MARK: Notifications from further in history
                    Section() {
                        ForEach(dataManager.notificationHistoryPrevious) { notificationModel in
                            if notificationModel.data.type == .upvote || notificationModel.data.type == .comment || notificationModel.data.type == .hot || notificationModel.data.type == .top || notificationModel.data.type == .reply {
                                
                                Button {
                                    DispatchQueue.main.async {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        notificationsVM.getPost(url: notificationModel.data.url!, id: notificationModel.id) { success in
                                            post = success
                                            postIsLinkActive = true
                                            notificationsVM.markNotificationAsRead(id: notificationModel.id)
                                        }
                                    }
                                } label: {
                                    getNotificationText(notificationModel: notificationModel)
                                }
                                .listRowBackground(!notificationModel.data.read ? Color.pongAccent.opacity(0.1) : Color.pongSystemBackground)
                                .listRowSeparator(.hidden)
                            }
                            else if notificationModel.data.type == .leader {
                                Button {
                                    DispatchQueue.main.async {
                                        leaderboardIsLinkActive = true
                                        notificationsVM.markNotificationAsRead(id: notificationModel.id)
                                    }
                                } label: {
                                    getNotificationText(notificationModel: notificationModel)
                                }
                                .listRowBackground(!notificationModel.data.read ? Color.pongAccent.opacity(0.1) : Color.pongSystemBackground)
                                .listRowSeparator(.hidden)
                            }
                        }
                    } header: {
                        HStack {
                            Text("Previous")
                                .fontWeight(.heavy)
                                .foregroundColor(Color.pongLabel)
                                .padding(.bottom, 4)
                            
                            Spacer()
                            
                            if !thisWeekShowing {
                                Button {
                                    notificationsVM.markAllAsRead()
                                } label: {
                                    Text("Mark All Read")
                                        .foregroundColor(Color.pongAccent)
                                        .bold()
                                }
                            }
                        }
                    }
                    
                    Rectangle()
                        .fill(Color.pongSystemBackground)
                        .listRowBackground(Color.pongSystemBackground)
                        .frame(minHeight: 150)
                        .listRowSeparator(.hidden)
                }
            }
            .scrollContentBackgroundCompat()
            .refreshable() {
                notificationsVM.getNotificationHistoryWeek()
                notificationsVM.getNotificationHistoryPrevious()
            }
            .listStyle(PlainListStyle())
        }
        .background(Color.pongSystemBackground)
        .onAppear {
            UITableView.appearance().showsVerticalScrollIndicator = false
            notificationsVM.getAllNotifications()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color.pongLabel)
    }
    
    // MARK: GetNotificationText
    /// Returns the notifcation block based on the notification type
    func getNotificationText(notificationModel: NotificationsModel) -> some View {
        HStack {
            ZStack {
                if notificationModel.data.type == .hot || notificationModel.data.type == .comment || notificationModel.data.type == .leader || notificationModel.data.type == .reply {
                    Image(getImageNameFromType(type: notificationModel.data.type))
                        .foregroundColor(getColor(type: notificationModel.data.type))
                        .font(.title)
                } else {
                    Image(systemName: getImageNameFromType(type: notificationModel.data.type))
                        .foregroundColor(getColor(type: notificationModel.data.type))
                        .font(.title)
                }
            }
            .frame(width: 30, height: 30, alignment: .center)
            .cornerRadius(6)
            .padding(.trailing, 4)
            
            VStack (alignment: .leading, spacing: 6) {
                Text(notificationModel.notification.body)
                    .lineLimit(2)
                    .font(.headline)
            }
            .padding(.vertical, 1)
        }
    }
    
    // this stuff could just be a thing of the enum
    
    // MARK: GetImageNameFromType
    /// Returns the image name based on the notification type
    func getImageNameFromType(type: NotificationsModel.Data.NotificationType) -> String {
        switch type {
        case .upvote:
            return "arrow.up"
        case .comment:
            return "bubble.left.fill"
        case .hot:
            return "flame.fill"
        case .leader:
            return "trophy"
        case .reply:
            return "arrow.left.fill"
        case .violation:
            return "exclamationmark.triangle"
        case .generic:
            return "newspaper.fill"
        default:
            return "heart.fill"
        }
    }
    
    // MARK: GetGradientColorsFromType
    /// Returns the gradient colors based on the notification type
    func getColor(type: NotificationsModel.Data.NotificationType) -> Color {
        switch type {
        case .upvote:
            return .red
        case .comment:
            return .purple
        case .hot:
            return .orange
        case .leader:
            return .yellow
        case .reply:
            return .blue
        case .violation:
            return .red
        default:
            return Color.pongAccent
        }
    }
}

