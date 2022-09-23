import SwiftUI

struct NotificationsView: View {
    @StateObject private var notificationsVM = NotificationsViewModel()
    @ObservedObject private var notificationsManager = NotificationsManager.notificationsManager
    @EnvironmentObject var mainTabVM : MainTabViewModel
    @State private var searchText = ""
    @State private var showAlert = false
    @State var isLinkActive = false
//    @Environment(\.colorScheme) var colorScheme
    
    @State var post = defaultPost
    
    @ViewBuilder
    var body: some View {
        LoadingView(isShowing: .constant(false)) {
            NavigationView {
                VStack {
                    NavigationLink(destination: PostView(post: $post), isActive: $isLinkActive) { EmptyView() }
                    
                    List {
                        Section() {
                            if searchText.isEmpty && !notificationsManager.hasEnabledNotificationsOnce {
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    showAlert = true
                                }) {
                                    HStack {
                                        ZStack {
                                            LinearGradient(gradient: Gradient(colors: [Color.viewEventsGradient1, Color.viewEventsGradient2]), startPoint: .topTrailing, endPoint: .bottomLeading)
                                            Image(systemName: "bell")
                                                .imageScale(.small)
                                                .foregroundColor(.white)
                                                .font(.largeTitle)
                                        }
                                        .frame(width: 40, height: 40, alignment: .center)
                                        .cornerRadius(10)
                                        .padding(.trailing, 4)
                                        VStack (alignment: .leading, spacing: 6) {
                                            Text("Enable Notifications").foregroundColor(Color(uiColor: UIColor.label)).bold().lineLimit(1)
                                            HStack {
                                                Text("Never miss a message.").lineLimit(1).foregroundColor(.gray)
                                                Spacer()
                                            }
                                        }
                                        Spacer()
                                        ZStack {
                                            Circle()
                                                .fill(Color(UIColor.secondarySystemFill))
                                            Image(systemName: "hand.tap")
                                                .font(Font.body.weight(.bold))
                                                .foregroundColor(.gray)
                                        }
                                        .frame(width: 40, height: 40)

                                    }.padding(.vertical, 10)
                                    .alert(isPresented: $showAlert) {
                                        Alert(
                                            title: Text("Notifications Setup"),
                                            message: Text("Enable push notifications? You can always change this later in settings."),
                                            primaryButton: .destructive(
                                                Text("Don't Enable"),
                                                action: dontEnableNotifs
                                            ),
                                            secondaryButton: .default(
                                                Text("Enable"),
                                                action: notificationsManager.registerForNotifications
                                            )
                                        )
                                    }
                                }
                            }
                        }
                        Section(header: Text("Recent Notifications")) {
                            ForEach(notificationsVM.notificationHistory.filter { searchText.isEmpty || $0.notification.body.localizedStandardContains(searchText)}) { notificationModel in
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
                                }
                                else if notificationModel.data.type == .message  {
                                    NavigationLink(destination: Text("ref here")) {
                                        getNotificationText(notificationModel: notificationModel)
                                    }
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
                                }
                            }
                        }
                    }
                    .refreshable(action: {
                        print("DEBUG: Refreshed!")
                    })
                    .listStyle(GroupedListStyle())
                }
                .onAppear {
                    UITableView.appearance().showsVerticalScrollIndicator = false
                    notificationsVM.getNotificationHistory()
                }
                .navigationTitle("Notifications")
                .navigationBarTitleDisplayMode(.inline)			
                
            }
            .accentColor(Color(UIColor.label))
            .searchable(text: $searchText)
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
                    if notificationModel.notification.body == "" {
                        Text("Untitled Post")
                            .lineLimit(2)
                            .font(.headline)
                    } else {
                        Text(notificationModel.notification.body)
                            .lineLimit(2)
                            .font(.headline)
                    }

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
    
    func dontEnableNotifs() {
        
    }
}

//struct NotificationsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationsView()
//    }
//}
