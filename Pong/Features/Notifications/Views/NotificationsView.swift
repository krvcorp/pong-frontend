//
//  NotificationsView.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/5/22.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject private var notificationsVM = NotificationsViewModel()
    @State private var searchText = ""
    @State private var showAlert = false
    @Environment(\.colorScheme) var colorScheme
    
    struct NotificationModel: Identifiable {
        
        enum NotificationType: String {
            case upvote
            case comment
            case hot
            case top
            case leader
            case message
            case reply
            case violation
            case generic
        }
        
        var id: String { title }
        let title: String
        let type: NotificationType
    }
    

    let notificationModels: [NotificationModel] = [
        NotificationModel(title: "Your post \"fuck midterms\" reached 10 upvotes.", type: .upvote),
        NotificationModel(title: "Your post \"When you take a 10 minutes study break and it...\" has a new comment.", type: .comment),
        NotificationModel(title: "Your post \"When you take a 10 minutes study break and it...\" reached the hot page!", type: .hot),
        NotificationModel(title: "You made it to the leaderboard!", type: .leader),
        NotificationModel(title: "Your comment \"Returning to college after Thanksgiving break\" received a reply.", type: .reply),
        NotificationModel(title: "Your post \"goo goo ga ga\" was removed for violating our community guidelines.", type: .violation),
        NotificationModel(title: "Version 2.0 of Pong has launched! Tap to download now.", type: .generic),
    ]
    let chatmodels: [ChatModel] = [ChatModel(title: "Brattle street when jefes moves in", subtitle: "Why would you post that", timestamp: "6:09 PM", new: true, color1: Color.releaseNotesGradient1, color2: Color.releaseNotesGradient2),
                                   ChatModel(title: "I am getting housing at adams, but I'm also secretly", subtitle: "How much for the appt", timestamp: "4:20 PM", new: true, color1: Color.analyticsRevenueGradient1, color2: Color.analyticsRevenueGradient2),
                                   ChatModel(title: "Winthrop dining hall vibes are fire", subtitle: "No they're not", timestamp: "3:07 PM", new: false, color1: Color.webListItemGradient1, color2: Color.blue),
                                   ChatModel(title: "What if I 👉👈 got the HSA bigger bed", subtitle: "What if you didn't", timestamp: "2:59 PM", new: false, color1: Color.trackingLinksGradient1, color2: Color.trackingLinksGradient2),
                                   ChatModel(title: "is 1011a THAT hard...", subtitle: "Yes", timestamp: "1:06 PM", new: false, color1: Color.guestListGradient1, color2: Color.guestListGradient2)]
    
    var body: some View {
        LoadingView(isShowing: .constant(false)) {
            NavigationView {
                List {
                    Section() {
                        if searchText.isEmpty {
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
                                            action: enableNotifs
                                        ),
                                        secondaryButton: .default(
                                            Text("Enable"),
                                            action: dontEnableNotifs
                                        )
                                    )
                                }
                            }
                        }
                    }
                    Section(header: Text("Recent Notifications")) {
                        ForEach(notificationModels.filter { searchText.isEmpty || $0.title.localizedStandardContains(searchText)}) { notificationModel in
                            NavigationLink(destination: Text("ref here")) {
                                HStack {
                                    ZStack {
                                        LinearGradient(gradient: Gradient(colors: [getGradientColorsFromType(type: notificationModel.type).0, getGradientColorsFromType(type: notificationModel.type).1]), startPoint: .bottomLeading, endPoint: .topTrailing)
                                        Image(systemName: getImageNameFromType(type: notificationModel.type))
                                            .imageScale(.small)
                                            .foregroundColor(.white)
                                            .font(.title2)
                                    }
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .cornerRadius(6)
                                    .padding(.trailing, 4)
                                    VStack (alignment: .leading, spacing: 6) {
                                        Text(notificationModel.title).foregroundColor(Color(uiColor: colorScheme == .dark ? .white : .darkGray)).lineLimit(2).font(Font.caption)
                                    }.padding(.vertical, 1)
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .onAppear {
                    UITableView.appearance().showsVerticalScrollIndicator = false
                }
                .navigationTitle("Notifications")
            }
            .searchable(text: $searchText)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    func getImageNameFromType(type: NotificationModel.NotificationType) -> String {
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
    
    func getGradientColorsFromType(type: NotificationModel.NotificationType) -> (Color, Color) {
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
    
    func enableNotifs() {
        
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
