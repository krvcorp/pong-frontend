import SwiftUI

struct MessageRosterView: View {
    @StateObject var messageRosterVM = MessageRosterViewModel()
    @StateObject var dataManager = DataManager.shared
    
    @State private var searchText = ""
    @State private var showAlert = false
    
    var body: some View {
        List {
            if dataManager.conversations != [] {
                Section(header: (
                    searchBar
                        .listRowBackground(Color.pongSystemBackground)
                        .listRowSeparator(.hidden)
                )
                    .background(Color.pongSystemBackground)
                    .listRowInsets(EdgeInsets(
                        top: 0,
                        leading: 15,
                        bottom: 0,
                        trailing: 15))
                        .textCase(nil)
                ) {
                    EmptyView()
                }
            }
            
            
            
            if dataManager.conversations == [] {
                VStack(alignment: .center, spacing: 15) {

                    HStack(alignment: .center) {
                        Spacer()

                        Image("VoidImage")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.screenWidth / 2)

                        Spacer()
                    }
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Text("You have no conversations.")
                            .font(.title.bold())
                        Spacer()
                    }
                }
                .listRowBackground(Color.pongSystemBackground)
                .listRowSeparator(.hidden)
                .frame(height: UIScreen.screenHeight / 2)
            }
            // MARK: Conversations
            else {
                Section {
                    ForEach($dataManager.conversations.filter { searchText.isEmpty || $0.re.wrappedValue.contains(searchText)}, id: \.id) { $conversation in
                        ZStack {
                            NavigationLink(destination: MessageView(conversation: $conversation)) {
                                EmptyView()
                            }
                            .isDetailLink(false)
                            .opacity(0)
                            .buttonStyle(PlainButtonStyle())
                            
                            // HStack
                            // // VStack with
                            // // // HStack of conversation.re
                            // // // HStack of last message + dot + time of last message
                            // // Spacer
                            // Unread indicator if it exists
                            
                            
                            HStack {
                                VStack (alignment: .leading, spacing: 6) {
                                    
                                    // Conversation title (re)
                                    HStack {
                                        if conversation.re == "" {
                                            Text("This post was deleted")
                                                .fontWeight(.bold)
                                                .lineLimit(1)
                                                .font(.system(size: 16))
                                        } else {
                                            Text(conversation.re)
                                                .fontWeight(.bold)
                                                .lineLimit(1)
                                                .font(.system(size: 16))
                                        }
                                    }
                                     
                                    // Conversation's last message + time posted ago
                                    HStack {
                                        Text(conversation.messages.last!.message)
                                            .fontWeight(conversation.unreadCount == 0 ? .regular : .bold)
                                            .font(.system(size: 13))
                                            .lineLimit(1)
                                            .foregroundColor(conversation.unreadCount == 0 ? Color.pongLightGray : Color.pongLabel)
                                        
                                        if conversation.messages != [] {
                                            Text("• \(messageRosterVM.stringToDateToString(dateString: conversation.messages.last!.createdAt))")
                                                .foregroundColor(Color.pongLightGray)
                                                .fontWeight(.regular)
                                                .font(.system(size: 10))
                                                .lineLimit(1)
                                            
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                // put the number of unread messages in a circle
                                if conversation.unreadCount > 0 {
                                    Text("")
                                        .font(.system(size: 10))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color.white)
                                        .padding(4)
                                        .background(Color.pongAccent)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.vertical, 10)
                            
                        
                        }
//                        .padding(.vertical, 10)
                        .listRowBackground(Color.pongSystemBackground)
                        .listRowSeparator(.hidden)
                        
                        Rectangle()
                            .fill(Color.pongSecondarySystemBackground)
                            .frame(width: UIScreen.screenWidth - 50, height: 1)
                            .listRowBackground(Color.pongSecondarySystemBackground.edgesIgnoringSafeArea([.leading, .trailing]))
                            .listRowSeparator(.hidden)
                            .padding(0)
                            .listRowInsets(EdgeInsets())
                    }
                }
            }
        }
        .scrollContentBackgroundCompat()
        .background(Color.pongSystemBackground)
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(GroupedListStyle())
        .onAppear {
            UITableView.appearance().showsVerticalScrollIndicator = false
        }
        .onAppear() {
            messageRosterVM.getConversations(dataManager: dataManager)
        }
        .environment(\.defaultMinListRowHeight, 0)
    }
    
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(Color(hex: "B3B3B3"))
            TextField("Search for a conversation", text: $searchText)
                .font(Font.system(size: 16))
        }
        .padding(7)
        .background(Color.pongSearchBar)
        .cornerRadius(10)
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessageRosterView()
    }
}
