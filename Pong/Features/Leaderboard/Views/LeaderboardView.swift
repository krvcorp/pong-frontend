import SwiftUI
import AlertToast
import Combine

struct LeaderboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @StateObject private var leaderboardVM = LeaderboardViewModel()
    @StateObject var dataManager = DataManager.shared
    
    @State private var newPost = false
    @FocusState private var emojiIsFocused : Bool
    
    // MARK: Limit Text
    let textLimit = 20
    func limitText(_ upper: Int) {
        if dataManager.nickname.count > upper {
            dataManager.nickname = String(dataManager.nickname.prefix(upper))
        }
    }
    
    func limitEmojiText(_ upper: Int) {
        if emoji.count > upper {
            emoji = String(emoji.prefix(upper))
        }
    }
    
    @State private var nickname: String = ""
    @State private var emoji: String = ""
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            LeaderboardList
        }
        .background(Color.pongSystemBackground)
        .navigationBarTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                        Text(Image(systemName: "globe"))
                            .font(.title2)
                            .fontWeight(.bold)
                            
                        
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
                                Text("\(dataManager.rank)")
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
                        Text(Image(systemName: "star"))
                            .font(.title2)
                            .fontWeight(.bold)
                        
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
                
                Text(Image("upvote_box"))
                    .font(Font.system(size: 36, weight: .regular))
                
                Group {
                    if dataManager.rank == "1st" {
                        Text("You are first!")
                    } else {
                        Text("\(dataManager.karmaBehind)").fontWeight(.heavy) + Text(" points behind ") + Text("\(dataManager.rankBehind)").fontWeight(.heavy) + Text(" place")
                    }
                }
                
                Spacer()
            }
            .font(.title3)
            .foregroundColor(Color.pongAccent)
            
            // MARK: Editables
            HStack(spacing: 10) {
                
                // MARK: Nickname
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
                                .accentColor(Color.pongSystemWhite)
                                .onReceive(Just(dataManager.nickname)) { _ in limitText(textLimit) }
                                .placeholder(when: nickname.isEmpty) {
                                    if dataManager.nickname == "" {
                                        Text("Select a nickname")
                                            .foregroundColor(Color.pongSystemWhite)
                                    } else {
                                        Text("\(dataManager.nickname)")
                                            .foregroundColor(Color.pongSystemWhite)
                                    }
                                }
                                .submitLabel(.done)
                                .onSubmit {
                                    if nickname != dataManager.nickname && nickname != "" {
                                        leaderboardVM.updateNickname(dataManager: dataManager, nickname: nickname) { success in
                                            nickname = ""
                                        }
                                    }
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
                
                // MARK: Emoji
                VStack(alignment: .leading, spacing: 5) {
                    Text("EMOJI")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(Color.pongLabel)

                    HStack {
                        Image(systemName: "eye")
                        
                        EmojiTextField(text: $emoji, placeholder: "\(dataManager.emoji)")
                            .focused($emojiIsFocused)
                            .accentColor(Color.pongSystemWhite)
                            .onReceive(Just(emoji)) { _ in limitEmojiText(1) }
                            .padding(.horizontal)
                            .frame(width: 75)
                        
                        if emojiIsFocused {
                            Button  {
                                if emoji != dataManager.emoji && emoji != "" {
                                    leaderboardVM.updateNickname(dataManager: dataManager, emoji: emoji) { success in
                                        emoji = ""
                                    }
                                }
                            } label: {
                                Image("bookmark.fill")
                            }
                        }
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
