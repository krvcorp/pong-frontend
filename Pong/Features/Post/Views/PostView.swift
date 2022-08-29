import SwiftUI
import AlertToast
import MapKit

struct PostView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var setTabHelper : SetTabHelper
    @EnvironmentObject var dataManager: DataManager
    
    @Binding var post : Post
    @StateObject var postVM = PostViewModel()
    
    @State private var text = ""
    @State var sheet = false
    @State private var showScore = false
    @FocusState private var textIsFocused: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                mainPost
                
                LazyVStack {
                    ForEach($postVM.comments, id: \.self) { $comment in
                        CommentBubble(comment: $comment)
                            .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.bottom, 150)
            }
            
            MessagingComponent
        }
        .background(Color(UIColor.systemGroupedBackground))
        .environmentObject(postVM)
        .onAppear {
            DispatchQueue.main.async {
                // take binding and insert into VM
                postVM.post = self.post
                
                // api call to refresh local data
                postVM.readPost() { result in
                    if !result {
                        self.presentationMode.wrappedValue.dismiss()
                        dataManager.removePostLocally(post: post, message: "Post doesn't exist!")
                    }
                }
                
                // api call to fetch comments to display
                postVM.getComments()
            }
        }
        .onChange(of: postVM.updateTrigger) { newValue in
            DispatchQueue.main.async {
                self.post = postVM.post
            }
            dataManager.updatePostLocally(post: postVM.post)
        }
        .onChange(of: setTabHelper.trigger, perform: { newValue in
            DispatchQueue.main.async {
                self.presentationMode.wrappedValue.dismiss()
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        // MARK: Alerts and Toasts
        .alert(isPresented: $postVM.showDeletePostConfirmationView) {
            Alert(
                title: Text("Delete post"),
                message: Text("Are you sure you want to delete \(post.title)"),
                primaryButton: .destructive(Text("Delete")) {
                    postVM.deletePost(post: post, dataManager: dataManager)
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $postVM.showDeleteCommentConfirmationView) {
            Alert(
                title: Text("Delete comment"),
                message: Text("Are you sure you want to delete \(postVM.commentToDelete.comment)"),
                primaryButton: .destructive(Text("Delete")) {
                    postVM.deleteCommentConfirm()
                },
                secondaryButton: .cancel()
            )
        }
        .toast(isPresenting: $postVM.savedPostConfirmation){
            AlertToast(type: .regular, title: "Post saved!")
        }
        .toast(isPresenting: $postVM.removedComment){
            AlertToast(displayMode: .banner(.slide), type: .regular, title: "Comment deleted!")
        }
    }
    
    var mainPost: some View {
        VStack {
            VStack {
                HStack(alignment: .top){
                    VStack(alignment: .leading){
                        Text("\(postVM.post.timeSincePosted)")
                            .font(.caption)
                            .padding(.bottom, 4)

                                               
                        Text(postVM.post.title)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    VoteComponent
                }
                .padding(.bottom)
                
                // MARK: Poll
                if post.poll != nil {
                    PollView(post: $post)
                }
                
                bottomRow
            }
            .font(.system(size: 18).bold())
            .padding()
            .background(Color(UIColor.tertiarySystemBackground))

            ZStack {
                Divider()
                Text("\(postVM.post.numComments) Comments")
                    .font(.caption)
                    .background(Rectangle().fill(Color(UIColor.systemGroupedBackground)).frame(minWidth: 90))
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    var bottomRow: some View {
        HStack {
            Spacer()
            
            if post.saved {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postVM.unsavePost(post: post)
                } label: {
                    Image(systemName: "bookmark.fill")
                }
            } else if !post.saved {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postVM.savePost(post: post)
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
                ShareSheet(items: ["\(postVM.post.title)"])
            }
            
            // DELETE BUTTON
            if postVM.post.userOwned {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    DispatchQueue.main.async {
                        postVM.showDeletePostConfirmationView.toggle()
                    }
                } label: {
                    Image(systemName: "trash")
                }
            } else {
                Menu {
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.blockPost(post: post, dataManager: dataManager)
                    } label: {
                        Label("Block user", systemImage: "x.circle")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.reportPost(post: post, dataManager: dataManager)
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
                if postVM.post.voteStatus == 0 {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.postVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation {
                            showScore.toggle()
                        }

                    } label: {
                        Text("\(postVM.post.score)")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.postVote(direction: -1)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                }
                // MARK: if upvoted
                else if postVM.post.voteStatus == 1 {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.postVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                            .foregroundColor(Color(UIColor(named: "PongPrimary")!))
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation {
                            showScore.toggle()
                        }

                    } label: {
                        Text("\(postVM.post.score + 1)")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.postVote(direction: -1)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                }
                // MARK: if downvoted
                else if postVM.post.voteStatus == -1 {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.postVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation {
                            showScore.toggle()
                        }

                    } label: {
                        Text("\(postVM.post.score - 1)")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.postVote(direction: -1)
                    } label: {
                        Image(systemName: "arrow.down")
                            .foregroundColor(Color(UIColor(named: "PongPrimary")!))
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
            // MARK: Keyboard Down Component
            if textIsFocused {
                HStack {
                    Spacer()
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        textIsFocused = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 50, height: 50)
                    .background(Color(UIColor.tertiarySystemBackground).cornerRadius(5))
                }
                .padding()
            }
            
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
                        
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        if postVM.replyToComment == defaultComment {
                            postVM.createComment(comment: text)
                        } else {
                            postVM.commentReply(comment: text)
                            postVM.replyToComment = defaultComment
                        }
                        text = ""
                        withAnimation {
                            textIsFocused = false
                        }
                    } label: {
                        ZStack {
                            LinearGradient(gradient: Gradient(colors: [Color.viewEventsGradient1, Color.viewEventsGradient2]), startPoint: .topTrailing, endPoint: .bottomLeading)
                            Image(systemName: "paperplane.fill")
                                .imageScale(.small)
                                .foregroundColor(.white)
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
