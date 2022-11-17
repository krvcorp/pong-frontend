import SwiftUI
import Kingfisher

struct CommentBubble: View {
    @Binding var comment : Comment
    
    @StateObject var commentBubbleVM = CommentBubbleViewModel()
    @EnvironmentObject var postVM : PostViewModel
    @EnvironmentObject var dataManager : DataManager
    
    // MARK: Conversation
    @Binding var isLinkActive : Bool
    @Binding var conversation : Conversation
    
    // MARK: Body
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                commentTopRow
                    .padding(.horizontal)
                
                commentBody
                
                commentBottomRow
                    .padding(.horizontal)
            }
            .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.size.width)
            
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
        .padding(.top, 5)
        .background(Color.pongSystemBackground)
        .onAppear() {
            DispatchQueue.main.async {
                commentBubbleVM.comment = self.comment
            }
        }
        .onChange(of: commentBubbleVM.commentUpdateTrigger) { change in
            DispatchQueue.main.async {
                self.comment = commentBubbleVM.comment
            }
        }
    }
    
    // MARK: CommentTopRow
    var commentTopRow: some View {
        VStack(spacing: 5) {
            VStack(spacing: 0) {
                HStack {
                    Text("#\(comment.numberOnPost)")
                    
                    if let receiving = comment.numberReplyingTo {
                        Image(systemName: "arrow.right")
                        
                        Text("#\(receiving)")
                    }
                    
                    Spacer()
                    
                    // MARK: Menu Options
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
                        
//                        if comment.saved {
//                            Button {
//                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//        //                            postVM.saveComment(comment: comment, dataManager: dataManager)
//                            } label: {
//                                Label("Save", systemImage: "flag")
//                            }
//                        }
//                        else {
//                            Button {
//                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                                postVM.reportComment(comment: comment)
//                            } label: {
//                                Label("Unsave", systemImage: "flag.fill")
//                            }
//
//                        }
                        
                        if !comment.userOwned {
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                postVM.startConversation(comment: comment, dataManager: dataManager) { success in
                                    conversation = success
                                    isLinkActive = true
                                }
                            } label: {
                                Label("Start DM", systemImage: "envelope")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
                .font(.subheadline)
                .foregroundColor(Color.pongLabel)
                
                HStack {
                    Text("\(comment.timeSincePosted) ago")
                        .font(.caption)
                        .foregroundColor(Color.pongSecondaryText)
                    
                    Spacer()
                }
            }
            
            HStack {
                Text(comment.comment)
                    .bold()
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
        }
    }
    
    // MARK: CommentBody
    var commentBody: some View {
        VStack(alignment: .leading) {
            
            // MARK: Image
            if let imageUrl = comment.image {
                KFImage(URL(string: "\(imageUrl)")!)
                    .resizable()
                    .scaledToFit()
            }
        }
        .background(Color.pongSystemBackground)
    }
    
    // MARK: CommentBottomRow
    var commentBottomRow: some View {
        HStack(spacing: 20) {
            voteComponent
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                postVM.setCommentReply(comment: comment)
            } label: {
                Text("Reply")
                    .bold()
            }
            
            Spacer()
            
            if comment.userOwned {
                Button {
                    DispatchQueue.main.async {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.deleteComment(comment: comment)
                    }

                } label: {
                    Text("Delete")
                }
            }
        }
        .font(.headline)
        .foregroundColor(Color.pongSecondaryText)
        .padding(.top, 1)
    }
    
    // MARK: VoteComponent
    var voteComponent: some View {
        HStack {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                commentBubbleVM.commentVote(direction: 1, dataManager: dataManager)
            } label: {
                Text(Image(systemName: "arrow.up"))
                    .foregroundColor(comment.voteStatus == 1 ? Color.pongAccent : Color.pongSecondaryText)
                    .fontWeight(.bold)
            }
            
            Text("\(comment.score + comment.voteStatus)")
                .foregroundColor(Color.pongSecondaryText)
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                commentBubbleVM.commentVote(direction: -1, dataManager: dataManager)
            } label: {
                Text(Image(systemName: "arrow.down"))
                    .foregroundColor(comment.voteStatus == -1 ? Color.pongAccent : Color.pongSecondaryText)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
    }
}
