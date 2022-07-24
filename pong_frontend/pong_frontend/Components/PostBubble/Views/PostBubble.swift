//
//  Post.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct PostBubble: View {
    var post: Post
    @StateObject var postBubbleVM = PostBubbleViewModel()
    @State var sheet = false
    @State private var tapped = false
    @State private var showScore = false
//    @State var showingPopup = false
    
    var body: some View {
        // instead of navigationlink as a button, we use a container to toggle navigation link
        NavigationLink("", destination: PostView(post: post), isActive: $tapped)
        
        VStack {
            VStack {
                HStack(alignment: .top){
                    VStack(alignment: .leading){
                        
                        Text("\(post.timeSincePosted)")
                            .font(.caption)
                            .padding(.bottom, 4)
          
                        Text(post.title)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    VStack {
                        if !showScore {
                            Button {
                                postBubbleVM.postVote(id: post.id, direction: 1, currentDirection: 1) { result in
                                }
                            } label: {
                                Image(systemName: "arrow.up")
                            }
                            
                            Button {
                                print("DEBUG: Score check")
                                withAnimation {
                                    showScore.toggle()
                                }

                            } label: {
                                Text("\(post.score)")
                            }
                            
                            Button {
                                postBubbleVM.postVote(id: post.id, direction: -1, currentDirection: 1) { result in
                                }
                            } label: {
                                Image(systemName: "arrow.down")
                            }
                        } else {
                            Button {
                                print("DEBUG: Score check")
                                withAnimation {
                                    showScore.toggle()
                                }

                            } label: {
                                VStack {
                                    Text("\(post.score)")
                                        .foregroundColor(.green)
                                    Text("\(post.score)")
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
                    // comments, share, mail, flag
                    NavigationLink {
                        PostView(post: post)
                    }  label: {
                        Image(systemName: "bubble.left")
                        Text("\(post.numComments) comments")
                            .font(.subheadline).bold()
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
                        postBubbleVM.reportPost(postid: post.id) { result in }
//                        self.showingPopup = true
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
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.tertiarySystemBackground), lineWidth: 5))
        .background(Color(UIColor.tertiarySystemBackground)) // If you have this
        .cornerRadius(10)         // You also need the cornerRadius here
        .onTapGesture {
            tapped.toggle()
        }
//        .popup(isPresented: $showingPopup, type: .toast, position: .bottom, dragToDismiss: true) {
//            // your content
//            ReportView()
//        }
    }
}

struct PostBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        PostBubble(post: defaultPost)
    }
}
