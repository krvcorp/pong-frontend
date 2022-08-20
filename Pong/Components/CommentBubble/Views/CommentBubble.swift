//
//  CommentBubble.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/7/22.
//

import SwiftUI

struct CommentBubble: View {
    @Binding var comment : Comment
    @StateObject var commentBubbleVM = CommentBubbleViewModel()
    @EnvironmentObject var postVM : PostViewModel
    
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
            ForEach($commentBubbleVM.comment.children, id: \.self) { $child in
                HStack {
                    Rectangle()
                        .fill(Color(UIColor.tertiarySystemBackground))
                        .frame(width: 20)
                    Spacer()
                    CommentBubble(comment: $child)
                        .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .background(Color(UIColor.tertiarySystemBackground))
        .onAppear {
            commentBubbleVM.comment = self.comment
        }
    }
    var CommentBody: some View {
        Button  {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            print("DEBUG: Reply to \(commentBubbleVM.comment.comment)")
            postVM.replyToComment = commentBubbleVM.comment
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
            .background(Color(UIColor.tertiarySystemBackground))
        }
    }
    
    var VoteComponent: some View {
        VStack {
            if !showScore {
                // MARK: if not upvoted or downvoted
                if commentBubbleVM.comment.voteStatus == 0 {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        commentBubbleVM.commentVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation {
                            showScore.toggle()
                        }
                    } label: {
                        Text("\(commentBubbleVM.comment.score)")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        commentBubbleVM.commentVote(direction: -1)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                }
                // MARK: if upvoted
                else if commentBubbleVM.comment.voteStatus == 1 {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        commentBubbleVM.commentVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.yellow)
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation {
                            showScore.toggle()
                        }

                    } label: {
                        Text("\(commentBubbleVM.comment.score + 1)")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        commentBubbleVM.commentVote(direction: -1)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                }
                // MARK: if downvoted
                else if commentBubbleVM.comment.voteStatus == -1 {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        commentBubbleVM.commentVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation {
                            showScore.toggle()
                        }

                    } label: {
                        Text("\(commentBubbleVM.comment.score - 1)")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        commentBubbleVM.commentVote(direction: -1)
                    } label: {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.yellow)
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
                        if commentBubbleVM.comment.voteStatus == 1 {
                            Text("\(commentBubbleVM.comment.numUpvotes + 1)")
                                .foregroundColor(.green)
                            Text("\(commentBubbleVM.comment.numDownvotes)")
                                .foregroundColor(.red)
                        }
                        else if commentBubbleVM.comment.voteStatus == -1 {
                            Text("\(commentBubbleVM.comment.numUpvotes)")
                                .foregroundColor(.green)
                            Text("\(commentBubbleVM.comment.numDownvotes + 1)")
                                .foregroundColor(.red)
                        }
                        else if commentBubbleVM.comment.voteStatus == 0 {
                            Text("\(commentBubbleVM.comment.numUpvotes)")
                                .foregroundColor(.green)
                            Text("\(commentBubbleVM.comment.numDownvotes)")
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
                print("DEBUG: Reply to \(commentBubbleVM.comment.comment)")
                postVM.replyToComment = commentBubbleVM.comment
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
                .background(Color(UIColor.tertiarySystemBackground))
            }

            
            // MARK: Delete or More Button
            if commentBubbleVM.comment.userOwned {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    commentBubbleVM.deleteComment()
                } label: {
                    Image(systemName: "trash")
                }
            } else {
                Menu {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        commentBubbleVM.saveComment()
                    } label: {
                        Label("Save", systemImage: "bookmark")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        commentBubbleVM.blockComment()
                    } label: {
                        Label("Block user", systemImage: "x.circle")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        commentBubbleVM.reportComment()
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
