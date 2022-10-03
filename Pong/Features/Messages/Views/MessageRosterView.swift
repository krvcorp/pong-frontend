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
    
    var body: some View {
        LoadingView(isShowing: .constant(false)) {
            List {
                // MARK: Messages
                Section(header: Text("Messages")) {
                    ForEach($dataManager.conversations.filter { searchText.isEmpty || $0.re.wrappedValue.contains(searchText)}, id: \.id) { $conversation in
                        NavigationLink(destination: MessageView(conversation: $conversation)) {
                            if conversation.read {
                                // if read
                                HStack {
                                    VStack (alignment: .leading, spacing: 6) {
                                        HStack {
                                            if conversation.re == "" {
                                                Text("Untitled Post")
                                                    .font(.subheadline)
                                                    .lineLimit(1)
                                            } else {
                                                Text(conversation.re)
                                                    .font(.subheadline)
                                                    .lineLimit(1)
                                            }
                                            
                                            Spacer()
                                            
                                            if conversation.messages != [] {
                                                Text(messageRosterVM.stringToDateToString(dateString: conversation.messages.last!.createdAt))
                                                    .font(.subheadline)
                                                    .foregroundColor(Color(UIColor.label))
                                                    .lineLimit(1)
                                                    
                                            }
                                        }

                                        
                                        if conversation.messages != [] {
                                            HStack {
                                                Text(conversation.messages.last!.message)
                                                    .font(.subheadline)
                                                    .lineLimit(1)
                                                    .foregroundColor(.gray)
                                                
                                                Spacer()
                                                
                                                Circle()
                                                    .fill(.clear)
                                                    .frame(width: 7, height: 7)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 10)
                            } else {
                                // if unread
                                HStack {
                                    VStack (alignment: .leading, spacing: 6) {
                                        HStack {
                                            if conversation.re == "" {
                                                Text("Untitled Post")
                                                    .font(.subheadline)
                                                    .bold()
                                                    .lineLimit(1)
                                            } else {
                                                Text(conversation.re)
                                                    .font(.subheadline)
                                                    .bold()
                                                    .lineLimit(1)
                                            }
                                            
                                            Spacer()
                                            
                                            if conversation.messages != [] {
                                                Text(messageRosterVM.stringToDateToString(dateString: conversation.messages.last!.createdAt))
                                                    .font(.subheadline)
                                                    .bold()
                                                    .foregroundColor(Color(UIColor.label))
                                                    .lineLimit(1)

                                            }
                                        }
                                        if conversation.messages != [] {
                                            HStack {
                                                Text(conversation.messages.last!.message)
                                                    .font(.subheadline)
                                                    .bold()
                                                    .foregroundColor(Color(UIColor.label))
                                                    .lineLimit(1)
                                                    .foregroundColor(.gray)

                                                Spacer()
                                                
                                                Circle()
                                                    .fill(Color(UIColor.systemBlue))
                                                    .frame(width: 7, height: 7)
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
