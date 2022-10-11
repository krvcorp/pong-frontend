import SwiftUI

struct MessageView: View {
    @State private var text = ""
    @Binding var conversation: Conversation
    @StateObject var messageVM : MessageViewModel = MessageViewModel()
    @EnvironmentObject var dataManager : DataManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                List {
                    Rectangle()
                        .fill(Color.pongSystemBackground)
                        .frame(height: 50)
                        .listRowBackground(Color.pongSystemBackground)
                        .listRowSeparator(.hidden)
                        .id("bottom")
                    
                    ForEach(messageVM.conversation.messages.reversed(), id: \.id) { message in
                        chatBubble(userOwned: message.userOwned, message: message)
                            .flippedUpsideDown()
                            .listRowBackground(Color.pongSystemBackground)
                            .listRowSeparator(.hidden)
                    }
                }
                .flippedUpsideDown()
                .onChange(of: conversation.messages, perform: { newValue in
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .top)
                    }

                })
                .onAppear() {
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .top)
                    }
                }
                .background(Color.pongSystemBackground)
                .listStyle(PlainListStyle())
            }
            
            MessageComponent
        }
        .background(Color.clear)
        // onAppear load binding conversation into viewmodel
        .onAppear {
            self.messageVM.conversation = conversation
        }
        .onChange(of: self.conversation.id, perform: { newValue in
            DispatchQueue.main.async {
                print("DEBUG: self.conversation.id.onChange")
                messageVM.conversation = self.conversation
            }
        })
        .navigationBarTitle("\(conversation.re)", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    messageVM.showBlockConfirmationView = true
                } label: {
                    Image(systemName: "person.fill.badge.minus")
                        .foregroundColor(Color(UIColor.label))
                }
            }
        }
        // MARK: Delete Confirmation
        .alert(isPresented: $messageVM.showBlockConfirmationView) {
            Alert(
                title: Text("Block user"),
                message: Text("Are you sure you want to block this user?"),
                primaryButton: .destructive(Text("Block")) {
                    messageVM.blockUser() { success in
                        dataManager.deleteConversationLocally(conversationId: conversation.id)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        // logic to start/stop polling
        .onReceive(messageVM.timer) { _ in
            if messageVM.timePassed % 5 != 0 {
                messageVM.timePassed += 1
            }
            else {
                messageVM.getConversation()
                messageVM.timePassed += 1
            }
        }
        .onAppear {
            self.messageVM.conversation.read = true
            self.messageVM.readConversation()
            self.messageVM.timer = Timer.publish (every: 1, on: .current, in: .common).autoconnect()
        }
        .onDisappear {
            self.messageVM.timer.upstream.connect().cancel()
        }
        // action to do on update of conversation model
        .onChange(of: messageVM.messageUpdateTrigger) { newValue in
            if self.conversation.messages != messageVM.conversation.messages {
                print("DEBUG: message written")
                self.messageVM.scrolledToBottom = false
                self.conversation.messages = messageVM.conversation.messages
                print("DEBUG: \(self.conversation.messages)")
            }
        }
    }
    
    @ViewBuilder
    func chatBubble(userOwned: Bool, message: Message) -> some View {
        HStack {
            if userOwned {
                Spacer()
            }

            HStack {
                Text("\(message.message)")
                    .font(.headline)
                    .padding()
            }
            .foregroundColor(Color(UIColor.label))
            .background(userOwned ? Color.pongSystemBackground : Color(UIColor.quaternaryLabel))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(UIColor.quaternaryLabel), lineWidth: 1))
            
            if !userOwned {
                Spacer()
            }
        }
    }
    
    var MessageComponent : some View {
        VStack(spacing: 0) {
            
            // MARK: Messaging Component
            VStack {
                // MARK: TextArea and Button Component
                HStack {
                    TextField("Message", text: $text)
                        .font(.headline)
                        .padding(5)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(20)
                        
                    // button component, should not be clickable if text empty
                    if text == "" {
                        ZStack {
                            Image(systemName: "paperplane")
                                .imageScale(.small)
                                .foregroundColor(Color(UIColor.quaternaryLabel))
                                .font(.largeTitle)
                        }
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(10)
                    } else {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            print("DEBUG SEND MESSAGE")
                            messageVM.sendMessage(message: text)
                            text = ""
                            
                        } label: {
                            ZStack {
                                Image(systemName: "paperplane")
                                    .imageScale(.small)
                                    .foregroundColor(Color(UIColor.label))
                                    .font(.largeTitle)
                            }
                            .frame(width: 40, height: 40, alignment: .center)
                            .cornerRadius(10)
                        }
                    }

                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.pongSystemBackground, lineWidth: 2))
            }
            .background(Color.pongSystemBackground)
        }
        .mask(Rectangle().padding(.top, -20))
    }
}
