import SwiftUI
import AlertToast

struct LeaderboardNotificationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var leaderboardVM = LeaderboardViewModel()
    @StateObject var dataManager = DataManager.shared
    @State private var newPost = false
    
    @State var timeRemaining = 10
    @State var timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    @State var nickname: String = ""
    
    var body: some View {
        let lblist = dataManager.leaderboardList
        VStack {
            VStack {
                List {
                    HStack {
                        Text("Powered by [Guayaki Yerba Mate](https://guayaki.com/)")
                            .bold()
                        
                        Spacer()
                        
                        Button {
                            print("DEBUG: info")
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                    
                    karmaInfo
                        .padding([.leading, .top, .trailing])
                        .listRowSeparator(.hidden)
                    
                    LeaderboardTopThree(
                        hasTopThree: [
                            lblist.count >= 1,
                            lblist.count >= 2,
                            lblist.count >= 3,
                        ],
                        topThreeScores: [
                            lblist.count >= 1 ? lblist[0].score : 0,
                            lblist.count >= 2 ? lblist[1].score : 0,
                            lblist.count >= 3 ? lblist[2].score : 0,
                        ],
                        topThreeNicknames: [
                            lblist.count >= 1 ? (lblist[0].nickname == "" ? "---" : lblist[0].nickname) : "---",
                            lblist.count >= 2 ? (lblist[1].nickname == "" ? "---" : lblist[0].nickname) : "---",
                            lblist.count >= 3 ? (lblist[2].nickname == "" ? "---" : lblist[0].nickname) : "---",
                        ]
                    )
                    
                    HStack {
                        TextField(dataManager.nickname == "" ? "Nickname" : "\(dataManager.nickname)", text: $nickname)
                        
                        Button {
                            leaderboardVM.updateNickname(dataManager: dataManager, nickname: nickname) { _ in
                                self.nickname = ""
                            }
                            leaderboardVM.getLeaderboard(dataManager: dataManager)
                            leaderboardVM.getLoggedInUserInfo(dataManager: dataManager)
                        } label: {
                            Label("Save", systemImage: "pencil")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if (lblist.count > 3) {
                        Section(header: Text("Leaderboard")) {
                            HStack(alignment: .center) {
                                HStack() {
                                    Spacer()
                                    Text("Rank")
                                        .font(.headline)
                                        .bold()
                                    Spacer()
                                }
                                .frame(maxWidth: UIScreen.screenWidth / 3, alignment: .leading)
                                
                            
                                HStack() {
                                    Spacer()
                                    Text("Nickname")
                                        .font(.headline)
                                        .bold()
                                    Spacer()
                                }
                                .frame(maxWidth: UIScreen.screenWidth / 3, alignment: .leading)
                            
                            
                                HStack() {
                                    Spacer()
                                    Text("Karma")
                                        .font(.headline)
                                        .bold()
                                    Spacer()
                                }
                                .frame(maxWidth: UIScreen.screenWidth / 3, alignment: .leading)
                            }
                            .listRowSeparator(.visible)
                            
                            ForEach(lblist) { entry in
                                if !["1", "2", "3"].contains(entry.place) {
                                    HStack(alignment: .center) {
                                        
                                        HStack() {
                                            Spacer()
                                            Text(entry.place)
                                            Spacer()
                                        }
                                        .frame(maxWidth: UIScreen.screenWidth / 3, alignment: .leading)
                                    
                                        HStack() {
                                            Spacer()
                                            Text(entry.nickname != "" ? entry.nickname : "---")
                                            Spacer()
                                        }
                                        .frame(maxWidth: UIScreen.screenWidth / 3, alignment: .leading)
                                    
                                        HStack() {
                                            Spacer()
                                            Text("\(entry.score)")
                                            Spacer()
                                        }
                                        .frame(maxWidth: UIScreen.screenWidth / 3, alignment: .leading)
                                    }
                                    .listRowSeparator(.hidden)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .onAppear {
                leaderboardVM.getLeaderboard(dataManager: dataManager)
                leaderboardVM.getLoggedInUserInfo(dataManager: dataManager)
            }
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Text("\(timeRemaining)")
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    }
                    else {
                        leaderboardVM.getLeaderboard(dataManager: dataManager)
                        leaderboardVM.getLoggedInUserInfo(dataManager: dataManager)
                        timeRemaining = 10
                    }
                }
        }
        .onTapGesture {
            print("DEBUG: onTap detected")
            hideKeyboard()
        }
        .toast(isPresenting: $leaderboardVM.savedNicknameAlert) {
            AlertToast(displayMode: .hud, type: .regular,  title: "Nickname saved!")
        }
        .onAppear {
            self.timer = Timer.publish (every: 1, on: .current, in: .common).autoconnect()
//            self.nickname = leaderboardVM.nickname
        }
        .onDisappear {
            self.timer.upstream.connect().cancel()
        }
    }
        
    
    var karmaInfo: some View {
        HStack(alignment: .center) {
            HStack() {
                Spacer()
                VStack(alignment: .center) {
                    Text("Total")
                        .font(.subheadline.bold())
                    Text(String(dataManager.totalKarma))
                        .font(.title2)
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                }
                Spacer()
            }
            .frame(maxWidth: UIScreen.screenWidth / 3, alignment: .leading)
            
        
            HStack() {
                Spacer()
                VStack(alignment: .center) {
                    Text("Post")
                        .font(.subheadline.bold())
                    Text(String(dataManager.postKarma))
                        .font(.title2)
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                }
                Spacer()
            }
            .frame(maxWidth: UIScreen.screenWidth / 3, alignment: .leading)
        
        
            HStack() {
                Spacer()
                VStack(alignment: .center) {
                    Text("Comment")
                        .font(.subheadline.bold())
                    Text(String(dataManager.commentKarma))
                        .font(.title2)
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                }

                Spacer()
            }
            .frame(maxWidth: UIScreen.screenWidth / 3, alignment: .leading)
        }
    }
}

