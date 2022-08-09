//
//  PostView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/4/22.
//

import SwiftUI

struct PostView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var post : Post
    @StateObject var postVM = PostViewModel()
    @State private var text = ""
    @State var sheet = false
    @State private var showScore = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RefreshableScrollView {
                mainPost
                LazyVStack {
                    ForEach($postVM.comments, id: \.self) { $comment in
                        CommentBubble(comment: $comment)
                            .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.bottom, 150)
            }
            .refreshable {
                print("DEBUG: Pull to refresh")
                postVM.readPost()
                postVM.getComments()
            }
            VStack(spacing: 0) {
                if postVM.replyToComment != defaultComment {
                    HStack {
                        Button {
                            print("DEBUG: remove reply")
                            postVM.replyToComment = defaultComment
                            text = ""
                        } label: {
                            Image(systemName: "xmark")
                        }

                        Text("Replying to: ").font(.subheadline) + Text("\(postVM.replyToComment.comment)").font(.subheadline.bold())
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .background(Color(UIColor.systemBackground))
                }
                HStack {
                    CustomTextField(placeholder: Text("Enter your message here"), text: $text)
                    Button {
                        if postVM.replyToComment == defaultComment {
                            postVM.createComment(comment: text)
                        } else {
                            postVM.commentReply(comment: text)
                            postVM.replyToComment = defaultComment
                        }
                        text = ""

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
        }
        .environmentObject(postVM)
        .onAppear {
            // take binding and insert into VM
            postVM.post = self.post
            
            // api call to refresh local data
            postVM.readPost()
            
            // api call to fetch comments to display
            postVM.getComments()
        }
        .onDisappear() {
            // prevent feedview from rebuilding but to update data
            self.post = postVM.post
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $postVM.showDeleteConfirmationView) {
            Alert(
                title: Text("Delete post"),
                message: Text("Are you sure you want to delete this post?"),
                primaryButton: .default(Text("Cancel")),
                secondaryButton: .destructive(Text("Delete")) {
                    postVM.deletePost()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    var mainPost: some View {
        VStack {
            VStack {
                HStack(alignment: .top){
                    VStack(alignment: .leading){
                        
                        Text("\(postVM.post.timeSincePosted)")
                            .font(.caption)
                            .padding(.bottom, 4)

                                               
                        Text(postVM.post.title)
                            .multilineTextAlignment(.leading)
                        
                    }
                    
                    Spacer()
                    
                    VoteComponent
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
                        ShareSheet(items: ["\(postVM.post.title)"])
                    }
                    
                    // DELETE BUTTON
                    if postVM.post.userOwned {
                        Button {
                            DispatchQueue.main.async {
                                postVM.showDeleteConfirmationView.toggle()
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
                        }
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
                Text("\(postVM.post.numComments) Comments")
                    .font(.caption)
                    .background(Rectangle().fill(Color(UIColor.systemBackground)).frame(minWidth: 90))
            }
        }
    }
    var VoteComponent: some View {
        VStack {
            if !showScore {
                // MARK: if not upvoted or downvoted
                if postVM.post.voteStatus == 0 {
                    Button {
                        postVM.postVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    
                    Button {
                        withAnimation {
                            showScore.toggle()
                        }

                    } label: {
                        Text("\(postVM.post.score)")
                    }
                    
                    Button {
                        postVM.postVote(direction: -1)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                }
                // MARK: if upvoted
                else if postVM.post.voteStatus == 1 {
                    Button {
                        postVM.postVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.yellow)
                    }
                    
                    Button {
                        withAnimation {
                            showScore.toggle()
                        }

                    } label: {
                        Text("\(postVM.post.score + 1)")
                    }
                    
                    Button {
                        postVM.postVote(direction: -1)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                }
                // MARK: if downvoted
                else if postVM.post.voteStatus == -1 {
                    Button {
                        postVM.postVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    
                    Button {
                        withAnimation {
                            showScore.toggle()
                        }

                    } label: {
                        Text("\(postVM.post.score - 1)")
                    }
                    
                    Button {
                        postVM.postVote(direction: -1)
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
                        if postVM.post.voteStatus == 1 {
                            Text("\(postVM.post.numUpvotes + 1)")
                                .foregroundColor(.green)
                            Text("\(postVM.post.numDownvotes)")
                                .foregroundColor(.red)
                        }
                        else if postVM.post.voteStatus == -1 {
                            Text("\(postVM.post.numUpvotes)")
                                .foregroundColor(.green)
                            Text("\(postVM.post.numDownvotes + 1)")
                                .foregroundColor(.red)
                        }
                        else if postVM.post.voteStatus == 0 {
                            Text("\(postVM.post.numUpvotes)")
                                .foregroundColor(.green)
                            Text("\(postVM.post.numDownvotes)")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .frame(width: 25, height: 50)
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(post: .constant(defaultPost))
    }
}
