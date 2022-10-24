import SwiftUI
import AlertToast

struct NotificationsView: View {
    @StateObject private var notificationsVM = NotificationsViewModel()
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var notificationsManager = NotificationsManager.notificationsManager
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
                    } else {
                        // MARK: Notifications
                        Section() {
                            ForEach(notificationsVM.notificationHistoryWeek) { notificationModel in
                                // MARK: Notifications for post/comments
                                if notificationModel.data.type == .upvote || notificationModel.data.type == .comment || notificationModel.data.type == .hot || notificationModel.data.type == .top || notificationModel.data.type == .reply {
                                    
                                    Button {
                                        DispatchQueue.main.async {
                                            notificationsVM.getPost(url: notificationModel.data.url!, id: notificationModel.id) { success in
                                                post = success
                                                postIsLinkActive = true
                                                notificationsVM.markNotificationAsRead(id: notificationModel.id)
                                            }
                                        }
                                    } label: {
                                        getNotificationText(notificationModel: notificationModel)
                                    }
                                    .listRowBackground(Color.pongSystemBackground)
                                    .listRowSeparator(.hidden)
                                    
                                }
                                // MARK: Notifications for leaderboard
                                else if notificationModel.data.type == .leader {
                                    Button {
                                        DispatchQueue.main.async {
                                            leaderboardIsLinkActive = true
                                            notificationsVM.markNotificationAsRead(id: notificationModel.id)
                                        }
                                    } label: {
                                        getNotificationText(notificationModel: notificationModel)
                                    }
                                    .listRowBackground(Color.pongSystemBackground)
                                    .listRowSeparator(.hidden)
                                }
                            }
                        } header: {
                            HStack {
                                Text("This Week")
                                    .fontWeight(.heavy)
                                    .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                                    .padding(.bottom, 4)
                                Spacer()
                                Button {
                                    notificationsVM.markAllAsRead()
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                        }
                        // MARK: Notifications from further in history
                        Section() {
                            ForEach(notificationsVM.notificationHistoryPrevious) { notificationModel in
                                if notificationModel.data.type == .upvote || notificationModel.data.type == .comment || notificationModel.data.type == .hot || notificationModel.data.type == .top || notificationModel.data.type == .reply {
                                    
                                    Button {
                                        DispatchQueue.main.async {
                                            notificationsVM.getPost(url: notificationModel.data.url!, id: notificationModel.id) { success in
                                                post = success
                                                postIsLinkActive = true
                                                notificationsVM.markNotificationAsRead(id: notificationModel.id)
                                            }
                                        }
                                    } label: {
                                        getNotificationText(notificationModel: notificationModel)
                                    }
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
                                    .listRowSeparator(.hidden)
                                }
                            }
                        } header: {
                            HStack {
                                Text("Previous")
                                    .fontWeight(.heavy)
                                    .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                                    .padding(.bottom, 4)
                            }
                        }
                    }

                }
                .refreshable() {
                    print("DEBUG: REFRESH")
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
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.inline)
            .accentColor(Color(UIColor.label))
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .toast(isPresenting: $dataManager.errorDetected) {
            AlertToast(displayMode: .hud, type: .error(Color.red), title: dataManager.errorDetectedMessage, subTitle: dataManager.errorDetectedSubMessage)
        }
    }
    
    func getNotificationText(notificationModel: NotificationsModel) -> some View {
        return
            HStack {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [getGradientColorsFromType(type: notificationModel.data.type).0, getGradientColorsFromType(type: notificationModel.data.type).1]), startPoint: .bottomLeading, endPoint: .topTrailing)
                    Image(systemName: getImageNameFromType(type: notificationModel.data.type))
                        .imageScale(.small)
                        .foregroundColor(.white)
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

                // if notification is unread, show a dot on the right side, otherwise, show nothing
                if !notificationModel.data.read {
                    Spacer()
                    Circle()
                        .frame(width: 8, height: 8, alignment: .center)
                        .foregroundColor(Color.lesleyUniversityPrimary)
                }
                
                
            }
    }
    
    
    
    func getImageNameFromType(type: NotificationsModel.Data.NotificationType) -> String {
        switch type {
        case .upvote:
            return "arrow.up"
        case .comment:
            return "text.bubble"
        case .hot:
            return "flame"
        case .leader:
            return "list.number"
        case .reply:
            return "arrowshape.turn.up.left"
        case .violation:
            return "exclamationmark.triangle"
        case .generic:
            return "newspaper"
        default:
            return "heart"
        }
    }
    
    func getGradientColorsFromType(type: NotificationsModel.Data.NotificationType) -> (Color, Color) {
        switch type {
        case .upvote:
            return (.earlyPeriod1, .earlyPeriod2)
        case .comment:
            return (.organicSearch1, .organicSearch2)
        case .hot:
            return (.sunburn1, .sunburn2)
        case .leader:
            return (.scientificLie1, .scientificLie2)
        case .reply:
            return (.codeLecture1, .codeLecture2)
        case .violation:
            return (.red, .red)
        default:
            return (.viewEventsGradient2, .viewEventsGradient1)
        }
    }
}

