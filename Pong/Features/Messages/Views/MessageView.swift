import SwiftUI

struct MessageView: View {
    @Binding var conversation: Conversation
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var messageVM : MessageViewModel = MessageViewModel()
    @EnvironmentObject var dataManager : DataManager
    
    @State var isLinkActive = false
    @State private var post = defaultPost
    @State private var text = ""

    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            // MARK: Navigate to PostView Component
            Button {
                DispatchQueue.main.async {
                    messageVM.getPost(postId: conversation.postId!) { success in
                        post = success
                        isLinkActive = true
                    }
                }
            } label: {
                PostComponent
                    .background(Color.pongSystemBackground)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
            .onAppear() {
                messageVM.readPost(postId: conversation.postId!)
            }
            
            // MARK: Rest of the messaging
            ZStack(alignment: .bottom) {
                // hidden postview
                NavigationLink(destination: PostView(post: $post), isActive: $isLinkActive) { EmptyView() }
                    .isDetailLink(false)
                // MARK: Actual content of the conversation's messages
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
                    .scrollContentBackgroundCompat()
                    .background(Color.pongSystemBackground)
                    .listStyle(PlainListStyle())
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
                }
                
                // MARK: OverLay of MessagingComponent
                messagingComponent()
                    .background(Color.pongSystemBackground)
                    .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        .background(Color.clear)
        // onAppear load binding conversation into viewmodel
        .onAppear {
            self.messageVM.conversation = conversation
        }
        .onChange(of: self.conversation.id) { newValue in
            DispatchQueue.main.async {
                messageVM.conversation = self.conversation
            }
        }
        .navigationBarTitle("Chat", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        messageVM.showBlockConfirmationView = true
                    } label: {
                        Label("Block user", systemImage: "x.circle")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        messageVM.showBlockConfirmationView = true
                    } label: {
                        Label("Report", systemImage: "flag")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 30, height: 30)
                }
                .foregroundColor(Color.pongLabel)
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
        .onAppear {
            self.conversation.unreadCount = 0
            self.messageVM.readConversation()
        }
        .onChange(of: messageVM.messageUpdateTrigger) { newValue in
            if self.conversation.messages != messageVM.conversation.messages {
                self.messageVM.scrolledToBottom = false
                self.conversation.messages = messageVM.conversation.messages
            }
        }
    }
    
    // MARK: ChatBubble
    @ViewBuilder
    func chatBubble(userOwned: Bool, message: Message) -> some View {
        HStack {
            if userOwned {
                Spacer()
            }

            HStack {
                Text("\(message.message)")
                    .font(.headline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
            }
            .foregroundColor(userOwned ? Color.white: Color.black)
            .background(userOwned ? Color.pongAccent : Color.pongGray)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(userOwned ? Color.pongAccent : Color.pongGray, lineWidth: 1))
            
            if !userOwned {
                Spacer()
            }
        }
    }
    
    // MARK: Overlay component to create a comment or reply
    @ViewBuilder
    func messagingComponent() -> some View {
        VStack(spacing: 0) {
            VStack {
                VStack {
                    
                    // MARK: Comment Overlay
                    HStack {
                        
                        // MARK: TextField
                        HStack {
                            TextField("Message", text: $text)
                                .font(.headline)
                        }
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(20)
                            
                        // MARK: PaperPlane
                        if text != "" {
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                messageVM.sendMessage(message: text) { success in
                                    text = ""
                                    NotificationsManager.shared.registerForNotifications(forceRegister: false)
                                }
                            } label: {
                                ZStack {
                                    Image("send")
                                        .imageScale(.large)
                                        .foregroundColor(Color.pongAccent)
                                        .font(.largeTitle)
                                }
                                .frame(width: 30, height: 40, alignment: .center)
                                .cornerRadius(10)
                            }
                        } else {
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            } label: {
                                ZStack {
                                    Image("send")
                                        .imageScale(.large)
                                        .foregroundColor(Color.pongAccent).opacity(0.25)
                                        .font(.largeTitle)
                                }
                                .frame(width: 30, height: 40, alignment: .center)
                                .cornerRadius(10)
                            }
                            .disabled(true)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 3)
            }
        }
        .padding(.top, 4)
    }
    
    // MARK: PostComponent
    var PostComponent: some View {
        HStack {
            HStack {
                VStack(spacing: 5) {
                    HStack {
                        Text("\(conversation.re)")
                            .font(.subheadline)
                            .lineLimit(2)
                        Spacer()
                    }
                    
                    HStack {
                        Text("\(conversation.reTimeAgo)")
                            .font(.caption)
                        Spacer()
                    }
                }
                .padding(5)
            }
            .foregroundColor(Color(UIColor.label))
            .background(Color(UIColor.quaternaryLabel))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.quaternaryLabel), lineWidth: 1))
            .padding(5)
        }
        .background(Color.pongSystemBackground)
        .frame(maxWidth: .infinity)
    }
}
