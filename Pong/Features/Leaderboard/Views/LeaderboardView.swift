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
        .navigationBarTitle("")
//        .navigationBarHidden(true)
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
        VStack(alignment: .leading) {
            // MARK: HEADER
            
            HStack {
                VStack(alignment: .leading) {
                    Image("PongTextLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 35)
                    
                    
                    
                    Text("LEADERBOARD")
                        .bold()
                        .font(.callout)
                }
                Spacer()
//                VStack {
//                    HStack{
//                        Spacer()
//                        Text("🏓")
//                            .font(.title)
//                    }
//                }
//                EmojiTextField(text: $text, placeholder: "Enter emoji")
            }
            
            
            // MARK: User Information
//            HStack {
//                HStack() {
//                    Spacer()
//                    VStack(alignment: .center) {
//                        Text("Total")
//                            .font(.subheadline.bold())
//                        Text(String(dataManager.totalKarma))
//                            .font(.title2)
//                            .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
//                    }
//                    Spacer()
//                }
//                .frame(maxWidth: UIScreen.screenWidth / 3, alignment: .leading)
//
//
//                HStack {
//                    Spacer()
//                    VStack(alignment: .center) {
//                        Text("Post")
//                            .font(.subheadline.bold())
//                        Text(String(dataManager.postKarma))
//                            .font(.title2)
//                            .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
//                    }
//                    Spacer()
//                }
//                .frame(maxWidth: UIScreen.screenWidth / 3, alignment: .leading)
//
//
//                HStack {
//                    Spacer()
//                    VStack(alignment: .center) {
//                        Text("Comment")
//                            .font(.subheadline.bold())
//                        Text(String(dataManager.commentKarma))
//                            .font(.title2)
//                            .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
//                    }
//
//                    Spacer()
//                }
//                .frame(maxWidth: UIScreen.screenWidth / 3, alignment: .leading)
//            }
            
            // MARK: Kahoot
//            HStack {
//                Group {
//                    Text("You're in")
//                        .font(.subheadline.bold())
//                    +
//                    Text(" 7th ")
//                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
//                        .font(.subheadline.bold())
//                    +
//                    Text("place!")
//                        .font(.subheadline.bold())
//                }
//            }
//
//            HStack {
//                Group {
//                    Text("20")
//                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
//                        .font(.subheadline.bold())
//                    +
//                    Text(" points behind ")
//                        .font(.subheadline.bold())
//                    +
//                    Text("Anon")
//                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
//                        .font(.subheadline.bold())
//                }
//            }
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
            
            
            
            CustomListDivider()
            
            
            //MARK: Contents
            Section {
                HStack {
                    HStack {
                        Text("RANK")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                            .bold()
                        Spacer()
                    }
                    .frame(maxWidth: UIScreen.screenWidth / 6, alignment: .leading)
                    
                    HStack {
                        Text("KARMA")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                            .bold()
                        Spacer()
                    }
                    .frame(maxWidth: UIScreen.screenWidth / 6, alignment: .leading)
                    
                    HStack {
                        Text("NICKNAME / SCHOOL")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                            .bold()
                        Spacer()
                    }
                    .frame(maxWidth: (UIScreen.screenWidth / 6) * 4, alignment: .leading)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.pongSystemBackground)
            }
            .padding(.leading, 30)
            
            ForEach(lblist) { entry in
//                if !["1", "2", "3"].contains(entry.place) {
                HStack {
                    
                    HStack {
                        Text(entry.place)
                            .bold()
                            .font(.title2)
                        Spacer()
                    }
                    .frame(maxWidth: UIScreen.screenWidth / 6, alignment: .leading)
                    
                    HStack {
                        Text("\(entry.score)")
                            .font(.headline)
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    .frame(maxWidth: UIScreen.screenWidth / 6, alignment: .leading)
                    
                    HStack {
//                        Text("🏓")
//                            .font(.title)
                        VStack {
                            HStack {
                                Text(entry.nickname != "" ? entry.nickname : "---")
                                    .bold()
                                    .foregroundColor(Color.red)
                                Spacer()
                            }
                            HStack {
                                Text("Boston University")
                                    .bold()
                                    .foregroundColor(Color.gray)
                                    .font(.system(size: 10))
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: (UIScreen.screenWidth / 6) * 4, alignment: .leading)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.pongSystemBackground)
                .padding(.leading, 30)
//                }
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
