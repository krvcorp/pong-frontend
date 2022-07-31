//
//  PostView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/4/22.
//

import SwiftUI

struct PostView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var feedVM : FeedViewModel
    @ObservedObject var postSettingsVM : PostSettingsViewModel
    @StateObject var postVM = PostViewModel()
    @State private var message = ""
    @State var sheet = false
    @Binding var post: Post
    @State private var showScore = false
    
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
                postVM.readPost(postId: post.id) { result in
                    switch result {
                    case .success(let post):
                        print("DEBUG: PostView Refreshable \(post)")
                        self.post = post
                        print("DEBUG: PostView Refreshable \(self.post)")
                    case .failure(let error):
                        print("DEBUG: PostView readPost failure \(error)")
                    }
                }
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
                                print("DEBUG: PostView createComment failure \(failure)")
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
                    BackButton()
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
                    
                    VoteComponent
                }
                .padding(.bottom)

                HStack {
                    // comments, share, mail, flag
                    Spacer()
                    
                    // DELETE BUTTON
                    if DAKeychain.shared["userId"] == post.user {
                        Button {
                            print("DEBUG: DELETE POST")
                            DispatchQueue.main.async {
                                postSettingsVM.post = post
                                postSettingsVM.showDeleteConfirmationView.toggle()
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                    
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
    var VoteComponent: some View {
        VStack {
            if !showScore {
                // if not upvoted or downvoted
                if post.voteStatus == 0 {
                    Button {
                        postVM.postVote(id: post.id, direction: 1, currentDirection: post.voteStatus) { result in
                            switch result {
                            case .success(let newVote):
                                self.post.voteStatus = newVote
                            case .failure(let error):
                                print("DEBUG: postBubbleVM.postVote error: \(error)")
                            }
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
                        postVM.postVote(id: post.id, direction: -1, currentDirection: post.voteStatus) { result in
                            switch result {
                            case .success(let newVote):
                                self.post.voteStatus = newVote
                            case .failure(let error):
                                print("DEBUG: postBubbleVM.postVote error: \(error)")
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                } else if post.voteStatus == 1 {
                    // if upvoted
                    Button {
                        postVM.postVote(id: post.id, direction: 1, currentDirection: post.voteStatus) { result in
                            switch result {
                            case .success(let newVote):
                                self.post.voteStatus = newVote
                            case .failure(let error):
                                print("DEBUG: postBubbleVM.postVote error: \(error)")
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.yellow)
                    }
                    
                    Button {
                        print("DEBUG: Score check")
                        withAnimation {
                            showScore.toggle()
                        }

                    } label: {
                        Text("\(post.score + 1)")
                    }
                    
                    Button {
                        postVM.postVote(id: post.id, direction: -1, currentDirection: post.voteStatus) { result in
                            switch result {
                            case .success(let newVote):
                                self.post.voteStatus = newVote
                            case .failure(let error):
                                print("DEBUG: postBubbleVM.postVote error: \(error)")
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                } else if post.voteStatus == -1 {
                    // if downvoted
                    Button {
                        postVM.postVote(id: post.id, direction: 1, currentDirection: post.voteStatus) { result in
                            switch result {
                            case .success(let newVote):
                                self.post.voteStatus = newVote
                            case .failure(let error):
                                print("DEBUG: postBubbleVM.postVote error: \(error)")
                            }
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
                        Text("\(post.score - 1)")
                    }
                    
                    Button {
                        postVM.postVote(id: post.id, direction: -1, currentDirection: post.voteStatus) { result in
                            switch result {
                            case .success(let newVote):
                                self.post.voteStatus = newVote
                            case .failure(let error):
                                print("DEBUG: postBubbleVM.postVote error: \(error)")
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.yellow)
                    }
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
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(feedVM: FeedViewModel(), postSettingsVM: PostSettingsViewModel(), post: .constant(defaultPost))
    }
}