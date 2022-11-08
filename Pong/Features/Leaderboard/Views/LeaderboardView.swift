import SwiftUI
import AlertToast
import Combine

struct LeaderboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject private var leaderboardVM = LeaderboardViewModel()
    @StateObject var dataManager = DataManager.shared
    @State private var newPost = false
    
    let textLimit = 20
    
    func limitText(_ upper: Int) {
        if nickname.count > upper {
            nickname = String(nickname.prefix(upper))
        }
    }
    
    @State var nickname: String = ""
    @State private var text: String = ""
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            LeaderboardList
        }
        .background(Color.pongSystemBackground)
        .onAppear {
            leaderboardVM.getLeaderboard(dataManager: dataManager)
            leaderboardVM.getLoggedInUserInfo(dataManager: dataManager)
        }
        .navigationBarTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            print("DEBUG: onTap detected")
            hideKeyboard()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toast(isPresenting: $leaderboardVM.savedNicknameAlert) {
            AlertToast(displayMode: .hud, type: .regular,  title: "Nickname saved!")
        }
    }
        
    // MARK: KarmaInfo
    var karmaInfo: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack {
                HStack {
                    Text("STATS")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(Color.pongLabel)
                    Spacer()
                }
                
                // MARK: First HSTACK of info
                HStack {
                    HStack {
                        Image(systemName: "globe")
                            .imageScale(.large)
                        
                        // MARK: Community Rank
                        VStack {
                            HStack {
                                Text("COMMUNITY RANK")
                                    .font(.caption)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color.pongLightGray)
                                Spacer()
                            }
                            
                            HStack {
                                Text("\(dataManager.totalKarma)")
                                    .font(.title3)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color.pongLabel)
                                
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: UIScreen.screenWidth / 2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.pongLightGray, lineWidth: 1)
                    )
                    
                    // MARK: User Karma
                    HStack {
                        Image(systemName: "star")
                            .imageScale(.large)
                        
                        VStack {
                            HStack {
                                Text("KARMA")
                                    .font(.caption)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color.pongLightGray)
                                Spacer()
                            }
                            
                            HStack {
                                Text("\(dataManager.totalKarma)")
                                    .font(.title3)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color.pongLabel)
                                
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: UIScreen.screenWidth / 2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.pongLightGray, lineWidth: 1)
                    )
                }
            }
            
            // MARK: Kahoot Component
            HStack {
                Spacer()
                Image(systemName: "bookmark")
                
                Group {
                    Text("400").fontWeight(.heavy) + Text(" points behind ") + Text("3rd").fontWeight(.heavy) + Text(" place")
                }
                Spacer()
            }
            .font(.title3)
            .foregroundColor(Color.pongAccent)
            
            // MARK: Editables
            HStack(spacing: 10) {
                VStack(spacing: 5) {
                    HStack {
                        Text("NICKNAME")
                            .font(.caption)
                            .fontWeight(.heavy)
                            .foregroundColor(Color.pongLabel)
                        Spacer()
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "person")
                            
                            TextField("", text: $nickname)
                                .onReceive(Just(nickname)) { _ in limitText(textLimit) }
                                .placeholder(when: nickname.isEmpty) {
                                    Text("Select a nickname").foregroundColor(Color.pongSystemWhite)
                                }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.pongAccent, lineWidth: 1)
                        )
                        .background(Color.pongAccent)
                        .cornerRadius(25)
                        .foregroundColor(Color.pongSystemWhite)
                        
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("EMOJI")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(Color.pongLabel)

                    HStack {
                        Image(systemName: "eye")
                        
                        Text("🏓")
                            .padding(.horizontal)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.pongAccent, lineWidth: 1)
                    )
                    .background(Color.pongAccent)
                    .cornerRadius(25)
                    .foregroundColor(Color.pongSystemWhite)
                }
            }
        }
        .background(Color.pongSystemBackground)
    }
    
    // MARK: LeaderboardList
    var LeaderboardList : some View {
        List {
            let lblist = dataManager.leaderboardList
            
            karmaInfo
                .listRowSeparator(.hidden)
                .listRowBackground(Color.pongSystemBackground)
            
            // MARK: Actual Leaderboard
            Text("LEADERBOARD")
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundColor(Color.pongLabel)
                .background(Color.pongSystemBackground)
                .listRowBackground(Color.pongSystemBackground)
            
            
            ForEach(lblist) { entry in
                HStack {
                    HStack {
                        Text("😛")
                            .font(.title)
                        
                        Spacer()
                    }
                    .frame(maxWidth: UIScreen.screenWidth / 6, alignment: .leading)
                    
                    HStack {
                        VStack {
                            HStack {
                                Text(entry.nickname != "" ? entry.nickname : "---")
                                    .bold()
                                    .font(.title2)
                                    .foregroundColor(Color.pongLabel)
                                Spacer()
                            }
                            
                            HStack {
                                Text("\(entry.score) karma")
                                    .bold()
                                    .foregroundColor(Color.pongLightGray)
                                    .font(.system(size: 10))
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: (UIScreen.screenWidth / 6) * 4, alignment: .leading)
                    
                    HStack {
                        Spacer()
                        
                        Text(entry.place)
                            .bold()
                            .font(.title2)
                            
                    }
                    .frame(maxWidth: UIScreen.screenWidth / 6, alignment: .leading)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.pongSystemBackground)
                .padding(.leading, 30)
            }
        }
        .scrollContentBackgroundCompat()
        .environment(\.defaultMinListRowHeight, 0)
        .background(Color.pongSystemBackground)
        .refreshable{
            leaderboardVM.getLeaderboard(dataManager: dataManager)
            leaderboardVM.getLoggedInUserInfo(dataManager: dataManager)
        }
        .listStyle(PlainListStyle())
    }
}
