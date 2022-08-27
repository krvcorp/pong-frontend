import SwiftUI
import AlertToast

struct ProfileCommentBubble: View {
    @Binding var comment : ProfileComment
    @StateObject var profileCommentBubbleVM = ProfileCommentBubbleViewModel()
    @EnvironmentObject var profileVM : ProfileViewModel
    
    // MARK: Some local view logic
    @State private var showScore = false
    @State private var sheet = false
    @State private var image = UIImage()
    
    var body: some View {
        VStack {
            commentBubbleMain

            Color.black.frame(height:CGFloat(1) / UIScreen.main.scale)
            
            HStack {
                
                ZStack {
                    NavigationLink(destination: PostView(post: $profileCommentBubbleVM.parentPost)) {
                        EmptyView()
                    }
                    .opacity(0.0)
                    .buttonStyle(PlainButtonStyle())
                    
                    HStack {
                        Text("Re: \(comment.re)")
                            .font(.subheadline).bold()

                        Spacer()
                    }
                }

                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    self.image = handleShare()
                    sheet.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .sheet(isPresented: $sheet) {
                    ShareSheet(items: [self.image])
                }
                
                // MARK: Delete or More Button
                 
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    DispatchQueue.main.async {
                        profileCommentBubbleVM.showDeleteConfirmationView.toggle()
                    }
                } label: {
                    Image(systemName: "trash")
                }
                
            }
        }
        .font(.system(size: 18).bold())
        .padding(0)
        .padding(.top, 10)
        
        
        // MARK: Delete Confirmation
        .alert(isPresented: $profileCommentBubbleVM.showDeleteConfirmationView) {
            Alert(
                title: Text("Delete comment"),
                message: Text("Are you sure you want to delete \(comment.comment)"),
                primaryButton: .destructive(Text("Delete")) {
                    profileCommentBubbleVM.deleteComment(comment: self.comment, profileVM: profileVM)
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            profileCommentBubbleVM.getParentPost(comment: comment)
        }
    }
    
    var commentBubbleMain: some View {
        ZStack {
            NavigationLink(destination: PostView(post: $profileCommentBubbleVM.parentPost)) {
                EmptyView()
            }
            .opacity(0.0)
            .buttonStyle(PlainButtonStyle())
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(comment.timeSincePosted)")
                        .font(.caption)
                        .padding(.bottom, 4)
      
                    Text(comment.comment)
                        .multilineTextAlignment(.leading)
                }
                .padding(.bottom)
                
                Spacer()
                
//                VoteComponent
            }
        }
    }
    
//    var VoteComponent: some View {
//        VStack {
//            if !showScore {
//                // if not upvoted or downvoted
//                if post.voteStatus == 0 {
//                    Button {
//                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                        postBubbleVM.postVote(direction: 1, post: post)
//                    } label: {
//                        Image(systemName: "arrow.up")
//                    }
//
//                    Button {
//                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                        withAnimation {
//                            showScore.toggle()
//                        }
//
//                    } label: {
//                        Text("\(post.score)")
//                    }
//
//                    Button {
//                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                        postBubbleVM.postVote(direction: -1, post: post)
//                    } label: {
//                        Image(systemName: "arrow.down")
//                    }
//                } else if post.voteStatus == 1 {
//                    // if upvoted
//                    Button {
//                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                        postBubbleVM.postVote(direction: 1, post: post)
//                    } label: {
//                        Image(systemName: "arrow.up")
//                            .foregroundColor(Color(UIColor(named: "PongPrimary")!))
//                    }
//
//                    Button {
//                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                        withAnimation {
//                            showScore.toggle()
//                        }
//
//                    } label: {
//                        Text("\(post.score + 1)")
//                    }
//
//                    Button {
//                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                        postBubbleVM.postVote(direction: -1, post: post)
//                    } label: {
//                        Image(systemName: "arrow.down")
//                    }
//                }
//                // IF POST BUBBLE IS DOWNVOTES
//                else if post.voteStatus == -1 {
//                    // upvote
//                    Button {
//                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                        postBubbleVM.postVote(direction: 1, post: post)
//                    } label: {
//                        Image(systemName: "arrow.up")
//                    }
//
//                    // score
//                    Button {
//                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                        withAnimation {
//                            showScore.toggle()
//                        }
//                    } label: {
//                        Text("\(post.score - 1)")
//                    }
//
//                    // downvote
//                    Button {
//                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                        postBubbleVM.postVote(direction: -1, post: post)
//                    } label: {
//                        Image(systemName: "arrow.down")
//                            .foregroundColor(Color(UIColor(named: "PongPrimary")!))
//                    }
//                }
//            } else {
//                Button {
//                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                    withAnimation {
//                        showScore.toggle()
//                    }
//
//                } label: {
//                    VStack {
//                        if post.voteStatus == 1 {
//                            Text("\(post.numUpvotes + 1)")
//                                .foregroundColor(.green)
//                            Text("\(post.numDownvotes)")
//                                .foregroundColor(.red)
//                        }
//                        else if post.voteStatus == -1 {
//                            Text("\(post.numUpvotes)")
//                                .foregroundColor(.green)
//                            Text("\(post.numDownvotes + 1)")
//                                .foregroundColor(.red)
//                        }
//                        else if post.voteStatus == 0 {
//                            Text("\(post.numUpvotes)")
//                                .foregroundColor(.green)
//                            Text("\(post.numDownvotes)")
//                                .foregroundColor(.red)
//                        }
//                    }
//                }
//            }
//        }
//        .frame(width: 25, height: 50)
//    }
    
    func handleShare() -> UIImage {
        let imageSize: CGSize = CGSize(width: 500, height: 800)
        let highresImage = commentBubbleMain.asImage(size: imageSize)
        return highresImage
    }
}


struct ProfileCommentBubble_Previews: PreviewProvider {
    static var previews: some View {
        PostBubble(post: .constant(defaultPost))
    }
}
