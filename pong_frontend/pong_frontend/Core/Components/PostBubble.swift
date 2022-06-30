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
                            
                            Text("\(post.user) ~ \(post.created_at)")
                                .font(.caption)
                                .padding(.bottom, 4)
              
                            Text(post.title)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        VStack{
                            Button {
                                viewModel.createPostVote(postid: post.id, direction: "up")
                            } label: {
                                Image(systemName: "arrow.up")
                            }
                            Text("\(post.total_score)")
                            Button {
                                viewModel.createPostVote(postid: post.id, direction: "down")
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
                                Text("\(post.num_comments) comments")
                            }
                        }

                        Spacer()
                        
                        Button {
                            self.uiimage = UIApplication.shared.windows[0].rootViewController?.view.asImage(rect: self.rect1)
                            sheet.toggle()

                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .buttonStyle(NoButtonStyle())
                        .sheet(isPresented: $sheet) {
                            ShareSheet(items: ["\(post.title)", uiimage])
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
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(UIColor.label), lineWidth: 10))
        }
        // remove highlight on tap
//        .buttonStyle(NoButtonStyle()) // this also removes button?
        .background(Color(UIColor.systemBackground)) // If you have this
        .cornerRadius(20)         // You also need the cornerRadius here
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
