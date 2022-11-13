//
//  MessagesView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/4/22.
//

import SwiftUI

struct MessageRosterView: View {
    @StateObject var messageRosterVM = MessageRosterViewModel()
    @EnvironmentObject var dataManager : DataManager
    
    @State private var searchText = ""
    @State private var showAlert = false
    
    var body: some View {
        List {
            // MARK: No Messages
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
                        Text("you have no messages")
                            .font(.title.bold())
                        Spacer()
                    }
                }
                .listRowBackground(Color.pongSystemBackground)
                .listRowSeparator(.hidden)
                .frame(height: UIScreen.screenHeight / 2)
            }
            // MARK: Messages
            else {
                Section() {
                    ForEach($dataManager.conversations.filter { searchText.isEmpty || $0.re.wrappedValue.contains(searchText)}, id: \.id) { $conversation in
                        ZStack {
                            NavigationLink(destination: MessageView(conversation: $conversation)) {
                                EmptyView()
                            }
                            .opacity(0)
                            .buttonStyle(PlainButtonStyle())
                            
                            HStack {
                                VStack (alignment: .leading, spacing: 6) {
                                    HStack {
                                        if conversation.re == "" {
                                            Text("Untitled Post")
                                                .lineLimit(1)
                                        } else {
                                            Text(conversation.re)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        if conversation.messages != [] {
                                            Text(messageRosterVM.stringToDateToString(dateString: conversation.messages.last!.createdAt))
                                                .foregroundColor(Color(UIColor.label))
                                                .lineLimit(1)
                                                
                                        }
                                    }
                                    
                                    if conversation.messages != [] {
                                        HStack {
                                            Text(conversation.messages.last!.message)
                                                .lineLimit(1)
                                                .foregroundColor(Color.pongSecondaryText)
                                            
                                            Spacer()
                                            
                                            // put the number of unread messages in a circle
                                            if conversation.unreadCount > 0 {
                                                Text("\(conversation.unreadCount)")
                                                    .font(.subheadline)
                                                    .foregroundColor(Color.white)
                                                    .padding(5)
                                                    .background(Color.pongAccent)
                                                    .clipShape(Circle())
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                            .font(conversation.unreadCount == 0 ? .subheadline : .subheadline.bold())
                        }
                        .listRowBackground(Color.pongSystemBackground)
                    }
                }
            }
        }
        .scrollContentBackgroundCompat()
        .searchable(text: $searchText)
        .background(Color.pongSystemBackground)
        .listStyle(GroupedListStyle())
        .onAppear {
            UITableView.appearance().showsVerticalScrollIndicator = false
        }
        .navigationTitle("Messages")
        .onAppear() {
            messageRosterVM.getConversations(dataManager: dataManager)
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessageRosterView()
    }
}
