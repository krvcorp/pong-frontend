//
//  Post.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct PostBubble: View {
    var post: Post
    var expanded: Bool
    @StateObject var viewModel = ComponentsViewModel()
    
    var body: some View {
        VStack {
            NavigationLink {
                PostView(post: post)
            } label: {
                VStack{
                    HStack(alignment: .top){
                        VStack(alignment: .leading){
                            
                            Text("\(post.user) ~ \(post.created_at)")
                                .font(.caption)
                                .padding(.bottom, 4)

                                                   
                            Text(post.title)
                                .multilineTextAlignment(.leading)
                            
                        }
                        
                        Spacer()
                        
                        VStack{
                            Button {
                                print("DEBUG: Upvote")
                            } label: {
                                Image(systemName: "arrow.up")
                            }
                            Text("\(post.total_score)")
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
                        if expanded {
                            Button {
                                print("DEBUG: Reply")
                            } label: {
                                Text("Reply")
                                
                            }
                        } else {
                            Button {
                                print("DEBUG: Comments")
                            } label: {
                                Image(systemName: "bubble.left")
                                Text("\(post.num_comments) comments")
                            }
                        }

                        Spacer()
                        
                        Button {
                            print("DEBUG: Share")
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Button {
                            print("DEBUG: DM")
                        } label: {
                            Image(systemName: "envelope")
                        }
                        Button {
                            print("DEBUG: Report")
                        } label: {
                            Image(systemName: "flag")
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.size.width - 50)
                .font(.system(size: 18).bold())
                .padding()
                .foregroundColor(.black)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black, lineWidth: 10))
            }
            .background(Color.white) // If you have this
            .cornerRadius(20)         // You also need the cornerRadius here
        }
    }
}

struct Post_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PostBubble(post: default_post,
                       expanded: false)
        }
    }
}
