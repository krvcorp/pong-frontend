//
//  PostView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/4/22.
//

import SwiftUI

struct PostView: View {
    @Environment(\.presentationMode) var mode
    var post: Post
    
    var body: some View {
        VStack {
            ScrollView {
                mainPost
            }
        }
    }
    
    var postHeader: some View {
        ZStack{
            HStack(alignment: .center) {
                Button {
                    mode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                }
                .padding()
                Spacer()
            }
        }
    }
    
    var mainPost: some View {
        ScrollView {
            LazyVStack{
                Button(action: {
                    print("DEBUG: Open Post")
                }) {
                    VStack{
                        
                        HStack(alignment: .top){
                            VStack(alignment: .leading){
                                
                                Text("Anonymous ~ 4h")
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
                                Text("41")
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
                    .font(.system(size: 18).bold())
                    .padding()
                    .foregroundColor(.black)
                }
                .background(Color.white) // If you have this
                .cornerRadius(20)         // You also need the cornerRadius here
                ZStack {
                    Divider()
                    Text("2 Comments")
                        .font(.caption)
                        .background(Rectangle().fill(.white).frame(minWidth: 90))
                        
                }
                CommentBubble(comment: Comment(id: "12345",
                                               user: "rdaga",
                                               post: "12345",
                                               comment: "bro what",
                                               createdAt: Date(),
                                               updatedAt: Date()))
            }
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(post: Post(id: "12345",
                            user: "rdaga",
                            title: "Text Body",
                            createdAt: Date(),
                            updatedAt: Date(),
                            expanded: false))
    }
}
