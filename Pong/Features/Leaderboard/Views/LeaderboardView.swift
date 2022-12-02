import SwiftUI
import AlertToast
import Combine

struct LeaderboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @StateObject var dataManager : DataManager = DataManager.shared
    @StateObject private var leaderboardVM = LeaderboardViewModel()
    
    @State private var newPost = false
    
//    NICKNAME AND EMOJI STUFF
    @State var prevNickname : String = ""
    @State var prevEmoji : String = ""
    @FocusState private var nicknameIsFocused : Bool
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
            emoji = String(emoji.suffix(upper))
        }
    }
    
    @State private var nickname: String = ""
    @State private var emoji: String = ""
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            if dataManager.leaderboardInit {
                LeaderboardList
            } else {
                ProgressView()
            }

        }
        .background(Color.pongSystemBackground)
        .navigationBarTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            DispatchQueue.main.async {
                self.prevNickname = dataManager.nickname
                self.prevEmoji = dataManager.nicknameEmoji
            }
            
            if !dataManager.leaderboardInit {
                dataManager.initLeaderboard()
            }
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
                
                Text(Image("arrow.up.in.circle"))
                
                Group {
                    if dataManager.rank == "1st" {
                        Text("You are first!")
                    } else {
                        Text("\(dataManager.karmaBehind)").fontWeight(.heavy) + Text(" point\(dataManager.karmaBehind == 1 ? "" : "s") behind ") + Text("\(dataManager.rankBehind)").fontWeight(.heavy) + Text(" place")
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
                                .focused($nicknameIsFocused)
                                .accentColor(Color.pongSystemWhite)
                                .onReceive(Just(dataManager.nickname)) { _ in limitText(textLimit) }
                                .placeholder(when: nickname.isEmpty && !nicknameIsFocused) {
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
                                        dataManager.nickname = nickname
                                        leaderboardVM.updateNickname(dataManager: dataManager, nickname: nickname) { success in
                                            if success {
                                                DispatchQueue.main.async {
                                                    prevNickname = nickname
                                                    nickname = ""
                                                }
                                            }
                                            else {
                                                dataManager.nickname = prevNickname
                                            }
                                        }
                                    }
                                }
                            
                            Spacer()
                        }
                        .padding(8)
                        .frame(width: 200, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.pongAccent, lineWidth: 1)
                        )
                        .background(Color.pongAccent)
                        .cornerRadius(25)
                        .foregroundColor(Color.pongSystemWhite)
                        
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Button {
                            if !nicknameIsFocused {
                                DispatchQueue.main.async {
                                    nicknameIsFocused = true
                                }
                            }
                            else {
                                if nickname != dataManager.nickname && nickname != "" {
                                    dataManager.nickname = nickname
                                    leaderboardVM.updateNickname(dataManager: dataManager, nickname: nickname) { success in
                                        if success {
                                            DispatchQueue.main.async {
                                                prevNickname = nickname
                                                nickname = ""
                                                nicknameIsFocused = false
                                            }
                                        }
                                        else {
                                            dataManager.nickname = prevNickname
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text(nicknameIsFocused ? "save" : "edit")
                                .foregroundColor(Color.pongSecondaryText)
                                .font(.caption)
                                .fontWeight(.heavy)
                        }
                        .padding(.trailing, 10)
                        .buttonStyle(PlainButtonStyle())
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
                        
                        EmojiTextField(text: $emoji, placeholder: $dataManager.nicknameEmoji)
                            .focused($emojiIsFocused)
                            .accentColor(Color.pongSystemWhite)
                            .onReceive(Just(emoji)) { _ in limitEmojiText(1) }
                            .frame(width: 50)
                            .onChange(of: emojiIsFocused) { newValue in
                                if emojiIsFocused {
                                    dataManager.nicknameEmoji = ""
                                }
                            }
                        
                        Spacer()
                        
//                        if emojiIsFocused {
//                            Button {
//                                if emoji != dataManager.nicknameEmoji && emoji != "" {
//                                    dataManager.nicknameEmoji = emoji
//                                    leaderboardVM.updateNickname(dataManager: dataManager, emoji: emoji) { success in
//                                        if success {
//                                            DispatchQueue.main.async {
//                                                prevEmoji = emoji
//                                                emoji = ""
//                                            }
//                                        }
//                                        else {
//                                            dataManager.nicknameEmoji = prevEmoji
//                                        }
//                                    }
//                                }
//                            } label: {
//                                Image("bookmark.fill")
//                                    .foregroundColor(Color.pongSystemWhite)
//                            }
//                        }
                    }
                    .padding(8)
                    .frame(width: 125, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.pongAccent, lineWidth: 1)
                    )
                    .background(Color.pongAccent)
                    .cornerRadius(25)
                    .foregroundColor(Color.pongSystemWhite)
                    
                    HStack {
                        Spacer()
                        Button {
                            if !emojiIsFocused {
                                DispatchQueue.main.async {
                                    emojiIsFocused = true
                                }
                            }
                            else {
                                if emoji != dataManager.nicknameEmoji && emoji != "" {
                                    dataManager.nicknameEmoji = emoji
                                    leaderboardVM.updateNickname(dataManager: dataManager, emoji: emoji) { success in
                                        if success {
                                            DispatchQueue.main.async {
                                                prevEmoji = emoji
                                                emoji = ""
                                                emojiIsFocused = false
                                            }
                                        }
                                        else {
                                            DispatchQueue.main.async {
                                                dataManager.nicknameEmoji = prevEmoji
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text(emojiIsFocused ? "save" : "edit")
                                .foregroundColor(Color.pongSecondaryText)
                                .font(.caption)
                                .fontWeight(.heavy)
                        }
                        .padding(.trailing, 10)
                        .buttonStyle(PlainButtonStyle())
                    }
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
                        Text("\(entry.nicknameEmoji)")
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
            
            Rectangle()
                .fill(Color.pongSystemBackground)
                .listRowBackground(Color.pongSystemBackground)
                .frame(minHeight: 150)
                .listRowSeparator(.hidden)
        }
        .scrollContentBackgroundCompat()
        .environment(\.defaultMinListRowHeight, 0)
        .background(Color.pongSystemBackground)
        .refreshable{
            leaderboardVM.getLeaderboard(dataManager: dataManager)
            leaderboardVM.getLoggedInUserInfo(dataManager: dataManager)
            await Task.sleep(500_000_000)
        }
        .listStyle(PlainListStyle())
    }
}
