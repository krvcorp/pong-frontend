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
    @StateObject var postBubbleVM = PostBubbleViewModel()
    @State var sheet = false
    @State private var rect1: CGRect = .zero
    @State private var uiimage: UIImage? = nil
    
    var body: some View {
        NavigationLink {
            PostView(post: post)
        } label: {
            VStack {
                VStack {
                    HStack(alignment: .top){
                        VStack(alignment: .leading){
                            
                            Text("Anonymous - \(post.timeSincePosted)")
                                .font(.caption)
                                .padding(.bottom, 4)
              
                            Text(post.title)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        VStack{
                            Button {
                                postBubbleVM.postVote(postid: post.id, direction: "up") { result in
                                    
                                }
                            } label: {
                                Image(systemName: "arrow.up")
                            }
                            Text("\(post.score)")
                            Button {
                                postBubbleVM.postVote(postid: post.id, direction: "down") { result in
                                    
                                }
                            } label: {
                                Image(systemName: "arrow.down")
                            }
                        }
                    }
                    .padding(.bottom)

                    // bottom row of contents
                    HStack {
                        // comments, share, mail, flag
                        if expanded {
                            Button {
                                print("DEBUG: Reply")
                            } label: {
                                Text("Reply")
                            }
                        } else {
                            NavigationLink {
                                PostView(post: post)
                            }  label: {
                                Image(systemName: "bubble.left")
                                Text("\(post.numComments) comments")
                                    .font(.subheadline).bold()
                            }
                        }

                        Spacer()
                        
                        Button {
                            sheet.toggle()

                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .sheet(isPresented: $sheet) {
                            ShareSheet(items: ["\(post.title)"])
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
            }
            .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.size.width - 50)
            .font(.system(size: 18).bold())
            .padding()
            .foregroundColor(Color(UIColor.label))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(UIColor.secondaryLabel), lineWidth: 10))
        }
        // remove highlight on tap
//        .buttonStyle(NoButtonStyle()) // this also removes button?
        .background(Color(UIColor.systemBackground)) // If you have this
        .cornerRadius(20)         // You also need the cornerRadius here
    }
    
}
