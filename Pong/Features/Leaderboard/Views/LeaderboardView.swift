import SwiftUI

struct LeaderboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var leaderboardVM = LeaderboardViewModel()
    @EnvironmentObject var dataManager : DataManager
    @State private var newPost = false
    
    @State var timeRemaining = 10
    @State var timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    @State private var nickname: String = ""
    
    var body: some View {
        let lblist = dataManager.leaderboardList
        NavigationView {
            VStack {
                VStack {
                    List {
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
                            ]
                        )
                        
                        HStack {
                            TextField("Nickname", text: $nickname)
                            Button(action: {
                                leaderboardVM.updateNickname(nickname: nickname)
                            }) {
                                Label("Save", systemImage: "pencil")
                            }
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
        }
        .onAppear {
            self.timer = Timer.publish (every: 1, on: .current, in: .common).autoconnect()
            self.nickname = leaderboardVM.nickname
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

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
            .previewInterfaceOrientation(.portrait)
    }
}

