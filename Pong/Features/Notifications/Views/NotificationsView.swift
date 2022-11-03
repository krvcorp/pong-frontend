import SwiftUI
import AlertToast

struct NotificationsView: View {
    @StateObject private var notificationsVM = NotificationsViewModel()
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var notificationsManager = NotificationsManager.shared
    @EnvironmentObject var mainTabVM : MainTabViewModel
    @State private var showAlert = false
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State var post = defaultPost
    
    @State var postIsLinkActive = false
    @State var leaderboardIsLinkActive = false
    
    //MARK: Body
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: PostView(post: $post), isActive: $postIsLinkActive) { EmptyView() }
                NavigationLink(destination: LeaderboardView(), isActive: $leaderboardIsLinkActive) { EmptyView() }
                
                // MARK: List
                List {
                    // MARK: If No Notifications
                    if notificationsVM.notificationHistoryPrevious == [] && notificationsVM.notificationHistoryWeek == [] {
                        VStack(alignment: .center, spacing: 15) {
                            HStack(alignment: .center) {
                                Spacer()

                                Image("PongTransparentLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: UIScreen.screenWidth / 2)

                                Spacer()
                            }
                            
                            HStack(alignment: .center) {
                                Spacer()
                                Text("No notifications yet!")
                                    .font(.title.bold())
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.pongSystemBackground)
                        .listRowSeparator(.hidden)
                        
                    }
                    // MARK: Notifications
                    else {
                        Section() {
                            ForEach(notificationsVM.notificationHistoryWeek) { notificationModel in
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
                            }
                        }
                        // MARK: Notifications from further in history
                        Section() {
                            ForEach(notificationsVM.notificationHistoryPrevious) { notificationModel in
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
                            }
                        }
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
                notificationsVM.getNotificationHistoryWeek()
                notificationsVM.getNotificationHistoryPrevious()
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .accentColor(Color.pongLabel)
            .toolbar() {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        notificationsVM.markAllAsRead()
                    } label: {
                        Text("Mark all Read")
                            .foregroundColor(Color.pongAccent)
                            .bold()
                    }
                }
            }
        }
        .toast(isPresenting: $dataManager.errorDetected) {
            AlertToast(displayMode: .hud, type: .error(Color.red), title: dataManager.errorDetectedMessage, subTitle: dataManager.errorDetectedSubMessage)
        }
    }
    
    // MARK: GetNotificationText
    /// Returns the notifcation block based on the notification type
    func getNotificationText(notificationModel: NotificationsModel) -> some View {
        HStack {
            ZStack {
                Image(systemName: getImageNameFromType(type: notificationModel.data.type))
                    .imageScale(.small)
                    .foregroundColor(getColor(type: notificationModel.data.type))
                    .font(.title2)
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
            return "text.bubble.fill"
        case .hot:
            return "flame.fill"
        case .leader:
            return "list.number"
        case .reply:
            return "arrowshape.turn.up.left"
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
            return .blue
        case .hot:
            return .orange
        case .leader:
            return .yellow
        case .reply:
            return .purple
        case .violation:
            return .red
        default:
            return Color.pongAccent
        }
    }
}

