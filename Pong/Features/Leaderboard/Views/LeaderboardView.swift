import SwiftUI

struct LeaderboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var leaderboardVM = LeaderboardViewModel()
    @EnvironmentObject var dataManager : DataManager
    @State private var newPost = false
    
    @State var timeRemaining = 10
    @State var timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    
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
                        
                        if (lblist.count > 3) {
                            Section(header: Text("Leaderboard")) {
                                ForEach(lblist) { entry in
                                    if !["1", "2", "3"].contains(entry.place) {
                                        HStack {
                                            Text("\(entry.place).")
                                            Text("\(entry.score)")
                                            Spacer()
                                        }
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
                            leaderboardVM.getLeaderboard()
                            leaderboardVM.getLoggedInUserInfo()
                            timeRemaining = 10
                        }
                    }
            }
        }
        .onAppear{
            self.timer = Timer.publish (every: 1, on: .current, in: .common).autoconnect()
        }
        .onDisappear{
            self.timer.upstream.connect().cancel()
        }
    }
        
    
    var karmaInfo: some View {
        ZStack {
            HStack {
                VStack(alignment: .center) {
                    Text(String(dataManager.totalKarma))
                    Text("Total Karma")
                        .font(.system(size: 10.0))
                }
                Spacer()
            }

            VStack(alignment: .center) {
                Text(String(dataManager.postKarma))
                Text("Post Karma")
                    .font(.system(size: 10.0))
            }
            
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    Text(String(dataManager.commentKarma))
                    Text("Comment Karma")
                        .font(.system(size: 10.0))
                }
            }
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
            .previewInterfaceOrientation(.portrait)
    }
}

