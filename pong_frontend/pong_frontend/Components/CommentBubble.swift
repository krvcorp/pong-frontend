//
//  CommentBubble.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/7/22.
//

import SwiftUI

struct CommentBubble: View {
    var comment: Comment
    @StateObject var viewModel = PostBubbleViewModel()
    
    var body: some View {
        VStack {
            Button {
                print("DEBUG: Reply")
            } label: {
                VStack{
                    HStack(alignment: .top){
                        VStack(alignment: .leading){
                            
                            Text("\(comment.timeSincePosted)")
                                .font(.caption)
                                .padding(.bottom, 4)
                                                   
                            Text(comment.comment)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        VStack{
                            Button {
                                print("DEBUG: Upvote")
                            } label: {
                                Image(systemName: "arrow.up")
                            }
                            Text("\(comment.score)")
                            Button {
                                print("DEBUG: Downvote")
                            } label: {
                                Image(systemName: "arrow.down")
                            }

                        }
                        
                    }
                    .padding(.bottom)
                    

                    //
                    HStack {
                        // comments, share, mail, flag

                        Button {
                            print("DEBUG: Reply")
                        } label: {
                            Text("Reply")
                                .font(.caption)
                        }
                        

                        Spacer()
                        
                        Button {
                            print("DEBUG: MORE")
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.size.width - 50)
                .font(.system(size: 18).bold())
                .padding()
                .foregroundColor(Color(UIColor.label))
            }
        }
    }
}

struct CommentBubble_Previews: PreviewProvider {
    static var previews: some View {
        CommentBubble(comment: defaultComment)
    }
}
