import SwiftUI

struct CommentBubble: View {
    @Binding var comment : Comment
    @StateObject var commentBubbleVM = CommentBubbleViewModel()
    @EnvironmentObject var postVM : PostViewModel
    @EnvironmentObject var dataManager : DataManager
    
    @State private var showScore = false
    
    var body: some View {
        VStack {
            VStack {
                HStack(alignment: .top) {
                    CommentBody
                    
                    Spacer()
                    
                    VoteComponent
                }

                // MARK: Bottom row
                CommentBottomRow
            }
            .padding()
            .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.size.width)
            .font(.system(size: 18).bold())
            .foregroundColor(Color(UIColor.label))
            
            // MARK: Recursive replies
            ForEach($comment.children, id: \.self) { $child in
                HStack {
                    Rectangle()
                        .fill(Color(UIColor.systemBackground))
                        .frame(width: 20)
                    Spacer()
                    CommentBubble(comment: $child)
                        .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .onChange(of: commentBubbleVM.comment) { change in
            self.comment = commentBubbleVM.comment
        }
        .onAppear() {
            commentBubbleVM.comment = self.comment
        }
    }
    
    var CommentBody: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            print("DEBUG: Reply to \(comment.comment)")
            postVM.replyToComment = comment
        } label: {
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
                }
                                       
                Text(comment.comment)
                    .multilineTextAlignment(.leading)
            }
            .padding(.bottom)
            .background(Color(UIColor.systemBackground))
        }
    }
    
    var VoteComponent: some View {
        VStack {
            if !showScore {
                // MARK: if not upvoted or downvoted
                if comment.voteStatus == 0 {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        commentBubbleVM.commentVote(direction: 1, dataManager: dataManager)
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    
                    Text("\(comment.score)")
//                    Button {
//                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                        withAnimation {
//                            showScore.toggle()
//                        }
//                    } label: {
//                        Text("\(comment.score)")
//                    }
                    
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
//                    Button {
//                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                        withAnimation {
//                            showScore.toggle()
//                        }
//
//                    } label: {
//                        Text("\(comment.score + 1)")
//                    }
                    
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
//                    Button {
//                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                        withAnimation {
//                            showScore.toggle()
//                        }
//
//                    } label: {
//                        Text("\(comment.score - 1)")
//                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        commentBubbleVM.commentVote(direction: -1, dataManager: dataManager)
                    } label: {
                        Image(systemName: "chevron.down")
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
                        if comment.voteStatus == 1 {
                            Text("\(comment.numUpvotes + 1)")
                                .foregroundColor(.green)
                            Text("\(comment.numDownvotes)")
                                .foregroundColor(.red)
                        }
                        else if comment.voteStatus == -1 {
                            Text("\(comment.numUpvotes)")
                                .foregroundColor(.green)
                            Text("\(comment.numDownvotes + 1)")
                                .foregroundColor(.red)
                        }
                        else if comment.voteStatus == 0 {
                            Text("\(comment.numUpvotes)")
                                .foregroundColor(.green)
                            Text("\(comment.numDownvotes)")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .frame(width: 25, height: 50)
    }
    
    var CommentBottomRow: some View {
        HStack {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                print("DEBUG: Reply to \(comment.comment)")
                postVM.replyToComment = comment
            } label: {
                HStack {
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [Color.viewEventsGradient1, Color.viewEventsGradient2]), startPoint: .bottomLeading, endPoint: .topTrailing)
                        Text("Reply").foregroundColor(Color(UIColor.black)).bold().lineLimit(1)
                    }
                    .cornerRadius(6)
                    .frame(width: 70, height: 10)

                    Spacer()
                }
                .background(Color(UIColor.systemBackground))
            }

            
            // MARK: Delete or More Button
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
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 30, height: 30)
                }
            }
        }
    }
}

struct CommentBubble_Previews: PreviewProvider {
    static var previews: some View {
        CommentBubble(comment: .constant(defaultComment))
    }
}
