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
                // MARK: Notification
                Section() {
                    if searchText.isEmpty {
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            showAlert = true
                        }) {
                            HStack {
                                ZStack {
                                    LinearGradient(gradient: Gradient(colors: [Color.viewEventsGradient1, Color.viewEventsGradient2]), startPoint: .topTrailing, endPoint: .bottomLeading)
                                    Image(systemName: "bell")
                                        .imageScale(.small)
                                        .foregroundColor(.white)
                                        .font(.largeTitle)
                                }
                                .frame(width: 40, height: 40, alignment: .center)
                                .cornerRadius(10)
                                .padding(.trailing, 4)
                                VStack (alignment: .leading, spacing: 6) {
                                    Text("Enable Notifications").foregroundColor(Color(uiColor: UIColor.label)).bold().lineLimit(1)
                                    HStack {
                                        Text("Never miss a message.").lineLimit(1).foregroundColor(.gray)
                                        Spacer()
                                    }
                                }
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(Color(UIColor.secondarySystemFill))
                                    Image(systemName: "hand.tap")
                                        .font(Font.body.weight(.bold))
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 40, height: 40)

                            }.padding(.vertical, 10)
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Notifications Setup"),
                                    message: Text("Enable push notifications? You can always change this later in settings."),
                                    primaryButton: .destructive(
                                        Text("Don't Enable"),
                                        action: enableNotifs
                                    ),
                                    secondaryButton: .default(
                                        Text("Enable"),
                                        action: dontEnableNotifs
                                    )
                                )
                            }
                        }
                    }
                }
                // MARK: Messages
                Section(header: Text("Messages")) {
                    ForEach($dataManager.conversations.filter { searchText.isEmpty || $0.re.wrappedValue.contains(searchText)}) { $conversation in
                        NavigationLink(destination: MessageView(conversation: $conversation)) {
                            HStack {
                                VStack (alignment: .leading, spacing: 6) {
                                    Text(conversation.re).bold().lineLimit(1)
                                    HStack {
                                        Text(conversation.messages.last!.message).lineLimit(1).foregroundColor(.gray)
                                        Spacer()
                                        ZStack {
                                            if !conversation.read {
                                                LinearGradient(gradient: Gradient(colors: [Color.viewEventsGradient1, Color.viewEventsGradient2]), startPoint: .bottomLeading, endPoint: .topTrailing)
                                            } else {
                                                Color(UIColor.secondarySystemFill)
                                            }
                                            if conversation.messages != [] {
                                                Text(messageRosterVM.stringToDateToString(dateString: conversation.messages.last!.createdAt))
                                                    .foregroundColor(conversation.read ? .white : .gray).bold().lineLimit(1)
                                                    .font(.caption)
                                            }
                                        }
                                        .cornerRadius(6)
                                        .frame(width: 75)
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                            .swipeActions {
                                Button("Delete") {
                                    print("DEBUG: delete the row")
                                }
                                .tint(.red)
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
