import SwiftUI

struct CommentBubble: View {
    @Binding var comment : Comment
    @StateObject var commentBubbleVM = CommentBubbleViewModel()
    @EnvironmentObject var postVM : PostViewModel
    @EnvironmentObject var dataManager : DataManager
    
    @State private var showScore = false
    
    // MARK: Conversation
    @Binding var isLinkActive : Bool
    @Binding var conversation : Conversation
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    CommentBody
                    Spacer()
                }
                CommentBottomRow
            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.size.width)
            .font(.system(size: 18).bold())
            
            // MARK: Recursive replies
            ForEach($comment.children, id: \.self) { $child in
                HStack {
                    Rectangle()
                        .fill(Color.pongSystemBackground)
                        .frame(width: 20)
                    Spacer()
                    CommentBubble(comment: $child, isLinkActive: $isLinkActive, conversation: $conversation)
                        .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .background(Color.pongSystemBackground)
        .onAppear() {
            DispatchQueue.main.async {
                commentBubbleVM.comment = self.comment
            }
        }
        .onChange(of: commentBubbleVM.commentUpdateTrigger) { change in
            print("DEBUG: old onChange self.comment.voteStatus \(self.comment.voteStatus)")
            print("DEBUG: new onChange VM.comment.voteStatus \(commentBubbleVM.comment.voteStatus)")
            // on change should be running twice when there's no internet?
            DispatchQueue.main.async {
                self.comment = commentBubbleVM.comment
            }
//            postVM.updateCommentLocally(comment: commentBubbleVM.comment)
        }
    }
    
    var CommentBody: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(comment.numberOnPost)")
                    .font(.headline.bold())
                    .padding(.bottom, 4)
                
                if let receiving = comment.numberReplyingTo {
                    Image(systemName: "arrow.right")
                        .scaledToFit()
                    
                    Text("\(receiving)")
                        .font(.headline.bold())
                        .padding(.bottom, 4)
                }
                
                Text("\(comment.timeSincePosted)")
                    .font(.caption)
                    .padding(.bottom, 4)
                
                Spacer()
                
                if !comment.userOwned {
                    Menu {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            postVM.blockComment(comment: comment)
                        } label: {
                            Label("Block user", systemImage: "x.circle")
                        }
                        
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            postVM.reportComment(comment: comment)
                        } label: {
                            Label("Report", systemImage: "flag")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .frame(width: 30, height: 30)
                    }
                }
            }
                                   
            Text(comment.comment)
                .multilineTextAlignment(.leading)
        }
        .background(Color.pongSystemBackground)
    }
    
    var VoteComponent: some View {
        HStack {
            // MARK: if not upvoted or downvoted
            if comment.voteStatus == 0 {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    commentBubbleVM.commentVote(direction: 1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.up")
                }
                
                
                Text("\(comment.score)")
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    commentBubbleVM.commentVote(direction: -1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.down")
                }
            }
            // MARK: if upvoted
            else if comment.voteStatus == 1 {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    commentBubbleVM.commentVote(direction: 1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.up")
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                }
                
                Text("\(comment.score + 1)")
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    commentBubbleVM.commentVote(direction: -1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.down")
                }
            }
            // MARK: if downvoted
            else if comment.voteStatus == -1 {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    commentBubbleVM.commentVote(direction: 1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.up")
                }
                
                Text("\(comment.score - 1)")
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    commentBubbleVM.commentVote(direction: -1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                }
            }
        }
        .frame(width: 100)
    }
    
    var CommentBottomRow: some View {
        HStack(spacing: 10) {
            
            
            Spacer()

            if !comment.userOwned {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postVM.startConversation(comment: comment, dataManager: dataManager) { success in
                        conversation = success
                        isLinkActive = true
                    }
                } label: {
                    Image(systemName: "paperplane")
                }
            }
            else {
                Button {
                    DispatchQueue.main.async {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.deleteComment(comment: comment)
                    }

                } label: {
                    Image(systemName: "trash")
                }
            }
        
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                postVM.setCommentReply(comment: comment)
            } label: {
                HStack {
                    Image(systemName: "arrowshape.turn.up.left")
                        .padding(3)
                        .foregroundColor(Color(UIColor.label))
                        .cornerRadius(6)
                        .frame(width: 15, height: 15)
                }
                .background(Color(UIColor.systemBackground))
            }
            
            VoteComponent
        }
    }
}
