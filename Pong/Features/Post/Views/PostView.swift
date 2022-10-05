import SwiftUI
import AlertToast
import MapKit
import Kingfisher

struct PostView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var mainTabVM : MainTabViewModel
    @EnvironmentObject var dataManager: DataManager
    
    @Binding var post : Post
    @StateObject var postVM = PostViewModel()
    @ObservedObject private var notificationsManager = NotificationsManager.notificationsManager
    
    @State private var text = ""
    @State var sheet = false
    @State private var showScore = false
    @FocusState private var textIsFocused : Bool
    
    // MARK: Conversation
    @State var isLinkActive = false
    @State var conversation = defaultConversation
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationLink(destination: MessageRosterView(), isActive: $postVM.openConversations) { EmptyView() }
            
            RefreshableScrollView {
                mainPost
                    .toast(isPresenting: $postVM.savedPostConfirmation) {
                        AlertToast(type: .regular, title: "Post saved!")
                    }
                
                LazyVStack {
                    ForEach($postVM.comments, id: \.self) { $comment in
                        CommentBubble(comment: $comment, isLinkActive: $isLinkActive, conversation: $conversation)
                            .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.bottom, 150)
            }
            .onTapGesture {
                print("DEBUG: onTap detected")
                hideKeyboard()
                self.postVM.textIsFocused = false
                self.textIsFocused = false
            }
            .refreshable {
                print("DEBUG: PostView refresh")
                // api call to refresh local data
                postVM.readPost(dataManager: dataManager) { result in
                    if !result {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                
                // api call to fetch comments to display
                postVM.getComments()
            }
            .background(Color(UIColor.secondarySystemBackground))
            
            MessagingComponent
        }
        .background(Color(UIColor.systemBackground))
        .environmentObject(postVM)
        .onAppear {
            DispatchQueue.main.async {
                // take binding and insert into VM
                postVM.post = self.post
                
                // api call to refresh local data
                postVM.readPost(dataManager: dataManager) { result in
                    if !result {
                        print("DEBUG: READ ERROR SHOULD DISMISS")
                        self.presentationMode.wrappedValue.dismiss()
                        
                        // THIS IS IF DELETED
                        dataManager.removePostLocally(post: post, message: "Post doesn't exist!")
                    }
                }
                
                // api call to fetch comments to display
                postVM.getComments()
            }
        }
        .onChange(of: postVM.postUpdateTrigger) { newValue in
            print("DEBUG: old onChange self.post.voteStatus \(self.post.voteStatus)")
            print("DEBUG: new onChange VM.post.voteStatus \(postVM.post.voteStatus)")
            DispatchQueue.main.async {
                self.post = postVM.post
            }
            dataManager.updatePostLocally(post: postVM.post)
        }
        .onChange(of: postVM.commentUpdateTrigger) { newValue in
            DispatchQueue.main.async {
                self.post = postVM.post
            }
            dataManager.updatePostLocally(post: postVM.post)
        }
        .onChange(of: mainTabVM.scrollToTop, perform: { newValue in
            DispatchQueue.main.async {
                self.presentationMode.wrappedValue.dismiss()
            }
        })
        .onChange(of: mainTabVM.newPostDetected, perform: { newValue in
            DispatchQueue.main.async {
                self.presentationMode.wrappedValue.dismiss()
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        // MARK: Alerts and Toasts
        .alert(isPresented: $postVM.showConfirmation) {
            switch postVM.activeAlert {
            case .postDelete:
                return Alert(
                    title: Text("Delete post"),
                    message: Text("Are you sure you want to delete \"\(post.title)\""),
                    primaryButton: .destructive(Text("Delete")) {
                        postVM.deletePost(post: post, dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )

            case .postReport:
                return Alert(
                    title: Text("Report post"),
                    message: Text("Are you sure you want to report \"\(post.title)\""),
                    primaryButton: .destructive(Text("Report")) {
                        postVM.reportPost(post: post, dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )

            case .postBlock:
                return Alert(
                    title: Text("Block post and user"),
                    message: Text("Are you sure you want to block content from this user?"),
                    primaryButton: .destructive(Text("Block")) {
                        postVM.blockPost(post: post, dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )
            case .commentDelete:
                return Alert(
                    title: Text("Delete comment"),
                    message: Text("Are you sure you want to delete \"\(postVM.commentToDelete.comment)\""),
                    primaryButton: .destructive(Text("Delete")) {
                        postVM.deleteCommentConfirm(dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )
            case .commentReport:
                return Alert(
                    title: Text("Report comment"),
                    message: Text("Are you sure you want to report \"\(postVM.commentToDelete.comment)\""),
                    primaryButton: .destructive(Text("Report")) {
                        postVM.deleteCommentConfirm(dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )
            case .commentBlock:
                return Alert(
                    title: Text("Block comment"),
                    message: Text("Are you sure you want to block content from this user?"),
                    primaryButton: .destructive(Text("Block")) {
                        postVM.deleteCommentConfirm(dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )
            case .pushNotifications:
                return Alert(
                    title: Text("Notifications Setup"),
                    message: Text("Enable push notifications? You can always change this later in settings."),
                    primaryButton: .destructive(
                        Text("Don't Enable"),
                        action: NotificationsManager.notificationsManager.dontEnableNotifs
                    ),
                    secondaryButton: .default(
                        Text("Enable"),
                        action: NotificationsManager.notificationsManager.registerForNotifications
                    )
                )
            }
        }
        .toast(isPresenting: $dataManager.removedComment) {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: dataManager.removedCommentMessage)
        }
    }
    
    var mainPost: some View {
        VStack {
            VStack {
                HStack(alignment: .top){
                    VStack(alignment: .leading){
                        Text("\(post.timeSincePosted)")
                            .font(.caption)
                            .padding(.bottom, 4)

                                               
                        Text(post.title)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    VoteComponent
                }
                .padding(.bottom)
                
                // MARK: Image
                if let imageUrl = post.image {
                    KFImage(URL(string: "\(imageUrl)")!)
                        .resizable()
                        .scaledToFit()
                        .frame(idealWidth: UIScreen.screenWidth / 1.1, idealHeight: CGFloat(post.imageHeight!) * (UIScreen.screenWidth / 1.1) / CGFloat(post.imageWidth!), maxHeight: CGFloat(150))
                        .cornerRadius(15)
                }
                
                // MARK: Poll
                if post.poll != nil {
                    PollView(post: $post)
                }
                
                bottomRow
            }
            .font(.system(size: 18).bold())
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    var bottomRow: some View {
        HStack {
            Spacer()
            
            if !post.userOwned {
                NavigationLink(destination: MessageView(conversation: $conversation), isActive: $isLinkActive) { EmptyView().opacity(0) }.opacity(0)
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postVM.startConversation(post: post, dataManager: dataManager) { success in
                        conversation = success
                        isLinkActive = true
                    }
                } label: {
                    Image(systemName: "paperplane")
                }
            }
            
            if post.saved {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postVM.unsavePost(post: post, dataManager: dataManager)
                } label: {
                    Image(systemName: "bookmark.fill")
                }
            } else if !post.saved {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postVM.savePost(post: post, dataManager: dataManager)
                } label: {
                    Image(systemName: "bookmark")
                }
            }
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                sheet.toggle()
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .sheet(isPresented: $sheet) {
                ShareSheet(items: ["\(post.title)"])
            }
            
            // DELETE BUTTON
            if post.userOwned {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    DispatchQueue.main.async {
                        postVM.activeAlert = .postDelete
                        postVM.showConfirmation = true
                    }
                } label: {
                    Image(systemName: "trash")
                }
            } else {
                Menu {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.activeAlert = .postBlock
                        postVM.showConfirmation = true
                    } label: {
                        Label("Block user", systemImage: "x.circle")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.activeAlert = .postReport
                        postVM.showConfirmation = true
                    } label: {
                        Label("Report", systemImage: "flag")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 30, height: 30)
                }
            }
        }
    }
    
    var VoteComponent: some View {
        VStack {
            if !showScore {
                // MARK: if not upvoted or downvoted
                if post.voteStatus == 0 {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.postVote(direction: 1, dataManager: dataManager)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    
                    Text("\(post.score)")
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.postVote(direction: -1, dataManager: dataManager)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                }
                // MARK: if upvoted
                else if post.voteStatus == 1 {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.postVote(direction: 1, dataManager: dataManager)
                    } label: {
                        Image(systemName: "arrow.up")
                            .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                    }
                    
                    Text("\(post.score + 1)")
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.postVote(direction: -1, dataManager: dataManager)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                }
                // MARK: if downvoted
                else if post.voteStatus == -1 {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.postVote(direction: 1, dataManager: dataManager)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    
                    Text("\(post.score - 1)")
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.postVote(direction: -1, dataManager: dataManager)
                    } label: {
                        Image(systemName: "arrow.down")
                            .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                    }
                }
            }
            // MARK: Show score
            else {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation {
                        showScore.toggle()
                    }

                } label: {
                    VStack {
                        if postVM.post.voteStatus == 1 {
                            Text("\(postVM.post.numUpvotes + 1)")
                                .foregroundColor(.green)
                            Text("\(postVM.post.numDownvotes)")
                                .foregroundColor(.red)
                        }
                        else if postVM.post.voteStatus == -1 {
                            Text("\(postVM.post.numUpvotes)")
                                .foregroundColor(.green)
                            Text("\(postVM.post.numDownvotes + 1)")
                                .foregroundColor(.red)
                        }
                        else if postVM.post.voteStatus == 0 {
                            Text("\(postVM.post.numUpvotes)")
                                .foregroundColor(.green)
                            Text("\(postVM.post.numDownvotes)")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .frame(width: 25, height: 50)
    }
    
    // MARK: Overlay component to create a comment or reply
    var MessagingComponent: some View {
        VStack(spacing: 0) {
            // MARK: Messaging Component
            VStack {
                // MARK: Reply to Component
                if postVM.replyToComment != defaultComment {
                    HStack {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            postVM.replyToComment = defaultComment
                            text = ""
                        } label: {
                            Image(systemName: "xmark")
                        }

                        Text("Replying to: ").font(.subheadline) + Text("\(postVM.replyToComment.comment)").font(.subheadline.bold())
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 2)
                }
                // MARK: TextArea and Button Component
                HStack {
                    TextField("Enter your message here", text: $text)
                        .font(.headline)
                        .focused($textIsFocused)
                        .onChange(of: postVM.textIsFocused) {
                            self.textIsFocused = $0
                        }
                        
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        if postVM.replyToComment == defaultComment {
                            postVM.createComment(comment: text, dataManager: dataManager, notificationsManager: notificationsManager)
                        } else {
                            postVM.commentReply(comment: text, dataManager: dataManager, notificationsManager: notificationsManager)
                            postVM.replyToComment = defaultComment
                        }
                        text = ""
                        withAnimation {
                            textIsFocused = false
                            postVM.textIsFocused = false
                        }
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
                .padding(.horizontal)
                .padding(.vertical, 3)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.secondarySystemBackground), lineWidth: 2))
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20, corners: [.topLeft, .topRight])
        }
        .shadow(color: Color(.black).opacity(0.3), radius: 10, x: 0, y: 0)
        .mask(Rectangle().padding(.top, -20))
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(post: .constant(defaultPost))
    }
}
