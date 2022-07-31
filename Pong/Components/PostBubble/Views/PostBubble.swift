//
//  Post.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct PostBubble: View {
    @State var post: Post
    @StateObject var postBubbleVM = PostBubbleViewModel()
    @StateObject private var loginVM = LoginViewModel()
    @ObservedObject var postSettingsVM : PostSettingsViewModel
    @ObservedObject var feedVM: FeedViewModel
    // navigation tracker
    @State private var tapped = false
    // local logic for karma
    @State private var showScore = false
    // share sheet
    @State var sheet = false
    
    var body: some View {
        // instead of navigationlink as a button, we use a container to toggle navigation link
        NavigationLink("", destination: PostView(feedVM: feedVM,postSettingsVM: postSettingsVM, post: $post), isActive: $tapped)
        
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
                    
                    // VOTE COMPONENT OF THIS POST BUBBLE
                    VoteComponent
                }
                .padding(.bottom)

                // BOTTOM ROW OF POST BUBBLE
                Color.black.frame(height:CGFloat(1) / UIScreen.main.scale)

                HStack {
                    // comments, share, mail, flag
                    Image(systemName: "bubble.left")
                    Text("\(post.numComments)")
                        .font(.subheadline).bold()

                    Spacer()
                    
                    // delete button if post id matches user id stored in keychain
                    if DAKeychain.shared["userId"] == post.user {
                        Button {
                            print("DEBUG: DELETE POST")
                            postSettingsVM.post = post
                            postSettingsVM.showDeleteConfirmationView.toggle()
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                    
                    // SHARE SHEET OF TEXT
                    Button {
                        sheet.toggle()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .sheet(isPresented: $sheet) {
                        ShareSheet(items: ["ponged: \(post.title)"])
                    }
                    
                     Button {
                         DispatchQueue.main.async {
                             postSettingsVM.showPostSettingsView.toggle()
                             postSettingsVM.post = self.post
                         }
                         
                     } label: {
                         Image(systemName: "ellipsis")
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
            feedVM.readPost(post: post) { result in
                switch result {
                case .success(let postResult):
                    self.post = postResult
                    tapped.toggle()

                case .failure(let errorMessage):
                    print("DEBUG: \(errorMessage)")
                }
            }
        }
    }
    
    var VoteComponent: some View {
        VStack {
            if !showScore {
                // if not upvoted or downvoted
                if post.voteStatus == 0 {
                    Button {
                        postBubbleVM.postVote(id: post.id, direction: 1, currentDirection: post.voteStatus) { result in
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
                        postBubbleVM.postVote(id: post.id, direction: -1, currentDirection: post.voteStatus) { result in
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
                        postBubbleVM.postVote(id: post.id, direction: 1, currentDirection: post.voteStatus) { result in
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
                        postBubbleVM.postVote(id: post.id, direction: -1, currentDirection: post.voteStatus) { result in
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
                        postBubbleVM.postVote(id: post.id, direction: 1, currentDirection: post.voteStatus) { result in
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
                        postBubbleVM.postVote(id: post.id, direction: -1, currentDirection: post.voteStatus) { result in
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



struct PostBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        PostBubble(post: defaultPost, postSettingsVM: PostSettingsViewModel(), feedVM: FeedViewModel())
    }
}