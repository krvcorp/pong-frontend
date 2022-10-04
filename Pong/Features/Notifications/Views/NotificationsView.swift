import SwiftUI

struct NotificationsView: View {
    @StateObject private var notificationsVM = NotificationsViewModel()
    @ObservedObject private var notificationsManager = NotificationsManager.notificationsManager
    @EnvironmentObject var mainTabVM : MainTabViewModel
    @State private var showAlert = false
    @State var isLinkActive = false
    
    @State var post = defaultPost
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: PostView(post: $post), isActive: $isLinkActive) { EmptyView() }
                
                List {
                    Section() {
                        ForEach(notificationsVM.notificationHistory) { notificationModel in
                            if notificationModel.data.type == .upvote || notificationModel.data.type == .comment || notificationModel.data.type == .hot || notificationModel.data.type == .top || notificationModel.data.type == .reply {
                                
                                Button {
                                    DispatchQueue.main.async {
                                        notificationsVM.getPost(url: notificationModel.data.url!) { success in
                                            post = success
                                            isLinkActive = true
                                        }
                                    }
                                } label: {
                                    getNotificationText(notificationModel: notificationModel)
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(notificationModel.data.read ? Color.pongSystemBackground : Color.notificationUnread)
                            }
                            else if notificationModel.data.type == .leader {
                                Button {
                                    DispatchQueue.main.async {
                                        mainTabVM.isCustomItemSelected = false
                                        mainTabVM.itemSelected = 2
                                    }
                                } label: {
                                    getNotificationText(notificationModel: notificationModel)
                                }
                                .listRowBackground(notificationModel.data.read ? Color.pongSystemBackground : Color.notificationUnread)
                                .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
                .refreshable(action: {
                    print("DEBUG: Refreshed!")
                })
                .listStyle(PlainListStyle())
            }
            .background(Color.pongSystemBackground)
            .onAppear {
                UITableView.appearance().showsVerticalScrollIndicator = false
                notificationsVM.getNotificationHistory()
            }
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.inline)
            .accentColor(Color(UIColor.label))
            .navigationViewStyle(StackNavigationViewStyle())
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
                        .background(notificationModel.data.read ? Color.pongSystemBackground : Color.notificationUnread)
                }
                .padding(.vertical, 1)
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

