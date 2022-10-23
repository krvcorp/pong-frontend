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
    
    // MARK: CommentBody
    var CommentBody: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("#\(comment.numberOnPost)")
                    .font(.caption)
                    .padding(.bottom, 1)
                
                if let receiving = comment.numberReplyingTo {
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .padding(.bottom, 1)
                    
                    Text("#\(receiving)")
                        .font(.caption)
                        .padding(.bottom, 1)
                }
                
                Spacer()
            }
            .foregroundColor(Color(UIColor.gray))
                                   
            Text(comment.comment)
                .bold()
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            if let imageUrl = comment.image {
                KFImage(URL(string: "\(imageUrl)")!)
                    .resizable()
                    .scaledToFit()
                    .frame(idealWidth: abs(UIScreen.screenWidth / 1.1), idealHeight: abs(CGFloat(comment.imageHeight!) * (UIScreen.screenWidth / 1.1) / CGFloat(comment.imageWidth!)), maxHeight: abs(CGFloat(150)))
                    .cornerRadius(15)
            }
                
        }
        .background(Color.pongSystemBackground)
    }
    
    var VoteComponent: some View {

        HStack {
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
    
    //MARK: CommentBottomRow
    var CommentBottomRow: some View {
        HStack() {
            Text("\(comment.timeSincePosted)")
            
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
                    Image(systemName: "trash")
                }
            } else {
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
            
            VoteComponent
        }
        .foregroundColor(Color.gray)
        .font(.headline)
        .padding(.top, 1)
    }
}
