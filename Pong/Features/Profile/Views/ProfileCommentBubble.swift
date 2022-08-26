import SwiftUI

struct ProfileCommentBubble: View { 
    @Binding var comment: ProfileComment
    @StateObject var profileCommentBubbleVM = ProfileCommentBubbleViewModel()
    // some local logic
    @State var sheet = false
    
    var body: some View {
        VStack {
            VStack {
                HStack(alignment: .top){
                    VStack(alignment: .leading){
                        
                        Text("\(comment.timeSincePosted)")
                            .font(.caption)
                            .padding(.bottom, 4)
          
                        Text(comment.comment)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    VStack {
                        if !showScore {
//                            Button {
//                                postBubbleVM.postVote(id: post.id, direction: 1, currentDirection: 1) { result in
//                                }
//                            } label: {
//                                Image(systemName: "arrow.up")
//                            }
                            
                            Button {
                                print("DEBUG: Score check")
                                withAnimation {
                                    showScore.toggle()
                                }

                            } label: {
                                Text("\(comment.score)")
                            }
                            
//                            Button {
//                                postBubbleVM.postVote(id: post.id, direction: -1, currentDirection: 1) { result in
//                                }
//                            } label: {
//                                Image(systemName: "arrow.down")
//                            }
                        } else {
                            Button {
                                print("DEBUG: Score check")
                                withAnimation {
                                    showScore.toggle()
                                }

                            } label: {
                                VStack {
                                    Text("\(comment.score)")
                                        .foregroundColor(.green)
                                    Text("\(comment.score)")
                                        .foregroundColor(.red)
                                }
                            }
                        }

                    }
                    .frame(width: 15, height: 50)
                }
                .padding(.bottom)

                Color.black.frame(height:CGFloat(1) / UIScreen.main.scale)
                
                // bottom row of contents
                HStack {

                    Image(systemName: "bubble.left")
                    Text("Re: \(comment.post.title)")
                        .font(.subheadline).bold()
                    

                    Spacer()
                    
                    
                    Button {
                        profileCommentBubbleVM.deleteComment(comment_id: comment.id)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.size.width - 50)
        .font(.system(size: 18).bold())
        .padding()
        .foregroundColor(Color(UIColor.label))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.tertiarySystemBackground), lineWidth: 5))
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
        .onAppear {
            if !hasAppeared {
                print("DEBUG: onAppear")
                profileCommentBubbleVM.readPost(postId: comment.post)
                hasAppeared.toggle()
            }
        }
        .padding(.top, 5)
    }
}

