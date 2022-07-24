//
//  PostView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/4/22.
//

import SwiftUI

struct PostView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var postVM = PostViewModel()
    @State private var message = ""
    @State var sheet = false
    @State var post: Post
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RefreshableScrollView {
                mainPost
                LazyVStack {
                    ForEach(post.comments) { comment in
                        CommentBubble(comment: comment)
                    }
                }
                .padding(.bottom, 150)
            }
            .refreshable {
                print("DEBUG: Pull to refresh")
                // when refreshing a get single post should be called to replace self.post
            }
           
            HStack {
                CustomTextField(placeholder: Text("Enter your message here"), text: $message)
                
                Button {
                    // creates coments and returns completion of the new comment
                    postVM.createComment(postid: post.id, comment: message) { result in
                        switch result {
                            case .success(let commentReturn):
                                self.post.comments.append(commentReturn)
                            case .failure(let failure):
                                print("DEBUG \(failure)")
                        }
                    }
                    message = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(Color(UIColor.systemBackground))
                        .padding(10)
                        .background(.indigo)
                        .cornerRadius(50)
                }
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemBackground), lineWidth: 2))
            .background(Color(UIColor.systemBackground))
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
            }
        }
    }
    
    var mainPost: some View {
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
                    
                    VStack{
                        Button {
                            postVM.postVote(id: post.id, direction: 1, currentDirection: 1) { result in
                            }
                        } label: {
                            Image(systemName: "arrow.up")
                        }
                        
                        Text("\(post.score)")
                        
                        Button {
                            postVM.postVote(id: post.id, direction: -1, currentDirection: -1) { result in
                            }
                        } label: {
                            Image(systemName: "arrow.down")
                        }
                    }
                }
                .padding(.bottom)

                HStack {
                    // comments, share, mail, flag
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
                        postVM.reportPost(postId: post.id) { result in
                            
                        }
                    } label: {
                        Image(systemName: "flag")
                    }
                }
            }
            .font(.system(size: 18).bold())
            .padding()
            .foregroundColor(Color(UIColor.label))
            .background(Color(UIColor.systemBackground)) // If you have this
            .cornerRadius(20)         // You also need the cornerRadius here

            ZStack {
                Divider()
                Text("\(post.numComments) Comments")
                    .font(.caption)
                    .background(Rectangle().fill(Color(UIColor.systemBackground)).frame(minWidth: 90))
            }
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(post: defaultPost)
    }
}
