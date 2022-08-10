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
            Button {
                print("DEBUG: Reply to \(commentBubbleVM.comment.comment)")
                postVM.replyToComment = commentBubbleVM.comment
            } label: {
                VStack{
                    HStack(alignment: .top){
                        VStack(alignment: .leading){
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
                        
                        Spacer()
                        
                        VoteComponent
                        
                    }
                    .padding(.bottom)

                    //
                    HStack {
                        // comments, share, mail, flag
                        Text("Reply")
                            .font(.caption)

                        Spacer()
                        
                        // DELETE BUTTON
                        if commentBubbleVM.comment.userOwned {
                            Button {
                                DispatchQueue.main.async {
                                    print("DEBUG: TRASH")
                                }
                            } label: {
                                Image(systemName: "trash")
                            }
                        } else {
                            Menu {
                                Button(action: {}) {
                                    Label("Save", systemImage: "bookmark")
                                }
                                
                                Button(action: {}) {
                                    Label("Block user", systemImage: "x.circle")
                                }
                                
                                Button(action: {}) {
                                    Label("Report", systemImage: "flag")
                                }
                            }
                            label: {
                                Image(systemName: "ellipsis")
                                    .frame(width: 30, height: 30)
                                    .highPriorityGesture(TapGesture())
                            }
                        }
                    }
                }
                .padding()
                .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.size.width)
                .font(.system(size: 18).bold())
                .foregroundColor(Color(UIColor.label))
            }
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
            // take binding and insert into VM
            print("DEBUG: commentBubble rebuild")
            commentBubbleVM.comment = self.comment
        }
    }
    
    var VoteComponent: some View {
        VStack {
            if !showScore {
                // MARK: if not upvoted or downvoted
                if commentBubbleVM.comment.voteStatus == 0 {
                    Button {
                        commentBubbleVM.commentVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    
                    Button {
                        withAnimation {
                            showScore.toggle()
                        }
                    } label: {
                        Text("\(commentBubbleVM.comment.score)")
                    }
                    
                    Button {
                        commentBubbleVM.commentVote(direction: -1)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                }
                // MARK: if upvoted
                else if commentBubbleVM.comment.voteStatus == 1 {
                    Button {
                        commentBubbleVM.commentVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.yellow)
                    }
                    
                    Button {
                        withAnimation {
                            showScore.toggle()
                        }

                    } label: {
                        Text("\(commentBubbleVM.comment.score + 1)")
                    }
                    
                    Button {
                        commentBubbleVM.commentVote(direction: -1)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                }
                // MARK: if downvoted
                else if commentBubbleVM.comment.voteStatus == -1 {
                    Button {
                        commentBubbleVM.commentVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    
                    Button {
                        withAnimation {
                            showScore.toggle()
                        }

                    } label: {
                        Text("\(commentBubbleVM.comment.score - 1)")
                    }
                    
                    Button {
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
                    withAnimation {
                        showScore.toggle()
                    }
                } label: {
                    VStack {
                        if commentBubbleVM.comment.score == 1 {
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
}

struct CommentBubble_Previews: PreviewProvider {
    static var previews: some View {
        CommentBubble(comment: .constant(defaultComment))
    }
}
