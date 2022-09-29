//
//  MessagesView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/4/22.
//

import SwiftUI

struct MessageRosterView: View {
    @State private var searchText = ""
    @State private var showAlert = false
    @StateObject var messageRosterVM = MessageRosterViewModel()
    @EnvironmentObject var dataManager : DataManager
    @EnvironmentObject var mainTabVM : MainTabViewModel
    
    var body: some View {
        LoadingView(isShowing: .constant(false)) {
            List {
                // MARK: Messages
                Section(header: Text("Messages")) {
                    ForEach($dataManager.conversations.filter { searchText.isEmpty || $0.re.wrappedValue.contains(searchText)}, id: \.id) { $conversation in
                        if conversation.id == mainTabVM.openConversation.id {
                            NavigationLink(destination: MessageView(conversation: $conversation), isActive: $mainTabVM.openConversationDetected) {
                                HStack {
                                    VStack (alignment: .leading, spacing: 6) {
                                        if conversation.re == "" {
                                            Text("Untitled Post").bold().lineLimit(1)
                                        } else {
                                            Text(conversation.re).bold().lineLimit(1)
                                        }
                                        
                                        if conversation.messages != [] {
                                            HStack {
                                                Text(conversation.messages.last!.message).lineLimit(1).foregroundColor(.gray)
                                                Spacer()
                                                ZStack {
                                                    if !conversation.read {
                                                        LinearGradient(gradient: Gradient(colors: [Color.viewEventsGradient1, Color.viewEventsGradient2]), startPoint: .bottomLeading, endPoint: .topTrailing)
                                                    } else {
                                                        Color(UIColor.secondarySystemFill)
                                                    }
                                                    
                                                    Text(messageRosterVM.stringToDateToString(dateString: conversation.messages.last!.createdAt))
                                                        .foregroundColor(conversation.read ? .white : .gray).bold().lineLimit(1)
                                                        .font(.caption)
                                                    
                                                }
                                                .cornerRadius(6)
                                                .frame(width: 75)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 10)
                            }
                            
                        } else {
                            NavigationLink(destination: MessageView(conversation: $conversation)) {
                                HStack {
                                    VStack (alignment: .leading, spacing: 6) {
                                        Text(conversation.re).bold().lineLimit(1)
                                        if conversation.messages != [] {
                                            HStack {
                                                Text(conversation.messages.last!.message).lineLimit(1).foregroundColor(.gray)
                                                Spacer()
                                                ZStack {
                                                    if !conversation.read {
                                                        LinearGradient(gradient: Gradient(colors: [Color.viewEventsGradient1, Color.viewEventsGradient2]), startPoint: .bottomLeading, endPoint: .topTrailing)
                                                    } else {
                                                        Color(UIColor.secondarySystemFill)
                                                    }
                                                    
                                                    Text(messageRosterVM.stringToDateToString(dateString: conversation.messages.last!.createdAt))
                                                        .foregroundColor(conversation.read ? .white : .gray).bold().lineLimit(1)
                                                        .font(.caption)
                                                    
                                                }
                                                .cornerRadius(6)
                                                .frame(width: 75)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 10)
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .onAppear {
                UITableView.appearance().showsVerticalScrollIndicator = false
            }
            .navigationTitle("Messages")
            .searchable(text: $searchText)
            .onReceive(messageRosterVM.timer) { _ in
                if messageRosterVM.timePassed % 5 != 0 {
                    messageRosterVM.timePassed += 1
                }
                else {
                    messageRosterVM.getConversations(dataManager: dataManager)
                    messageRosterVM.timePassed += 1
                }
            }
            .onAppear {
                messageRosterVM.getConversations(dataManager: dataManager)
                self.messageRosterVM.timer = Timer.publish (every: 1, on: .current, in: .common).autoconnect()
            }
            .onDisappear {
                self.messageRosterVM.timer.upstream.connect().cancel()
            }
        }
    }
    
    func dontEnableNotifs() {
        
    }
    
    func enableNotifs() {
        
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessageRosterView()
    }
}
