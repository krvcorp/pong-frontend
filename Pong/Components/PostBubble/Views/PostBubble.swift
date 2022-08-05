import SwiftUI

struct PostBubble: View {
    @ObservedObject var postBubbleVM : PostBubbleViewModel
    @ObservedObject var postSettingsVM : PostSettingsViewModel
    
    @State private var showScore = false
    @State var sheet = false
    
    init(post: Post, postSettingsVM: PostSettingsViewModel) {
        self.postBubbleVM = PostBubbleViewModel(post: post)
        self.postSettingsVM = postSettingsVM
    }
    
    @ViewBuilder
    var body: some View {
        VStack {
            HStack(alignment: .top){
                VStack(alignment: .leading){
                    Text("\(postBubbleVM.post.timeSincePosted)")
                        .font(.caption)
                        .padding(.bottom, 4)
      
                    Text(postBubbleVM.post.title)
                        .multilineTextAlignment(.leading)
                    
                    if let imageUrl = postBubbleVM.post.image {
                        AsyncImage(
                            url: URL(string: imageUrl),
                            content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            },
                            placeholder: {
                                ProgressView()
                            }
                        )
                    }
                      
                }
                
                Spacer()
                VoteComponent
            }
            .padding(.bottom)

            Color.black.frame(height:CGFloat(1) / UIScreen.main.scale)

            HStack {
                Image(systemName: "bubble.left")
                Text("\(postBubbleVM.post.numComments)")
                    .font(.subheadline).bold()

                Spacer()
                Button {
                    sheet.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .sheet(isPresented: $sheet) {
                    ShareSheet(items: ["ponged: \(postBubbleVM.post.title)"])
                }
                
                if postBubbleVM.post.userOwned {
                    Button {
                        DispatchQueue.main.async {
                            postSettingsVM.post = postBubbleVM.post
                            postSettingsVM.showDeleteConfirmationView.toggle()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                } else {
                    Button {
                        DispatchQueue.main.async {
                            postSettingsVM.showPostSettingsView.toggle()
                            postSettingsVM.post = postBubbleVM.post
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
        .padding(.top, 5) // this padding gives FeedView some spacing at the top
    }
    
    var VoteComponent: some View {
        VStack {
            if !showScore {
                // if not upvoted or downvoted
                if postBubbleVM.post.voteStatus == 0 {
                    Button {
                        postBubbleVM.postVote(direction: 1) { result in
                            switch result {
                            case .success(let postResponseBody):
                                if let voteStatus = postResponseBody.voteStatus {
                                    postBubbleVM.post.voteStatus = voteStatus
                                } else if let error = postResponseBody.error {
                                    print("DEBUG: \(error)")
                                }
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
                        Text("\(postBubbleVM.post.score)")
                    }
                    
                    Button {
                        postBubbleVM.postVote(direction: -1) { result in
                            switch result {
                            case .success(let postResponseBody):
                                if let voteStatus = postResponseBody.voteStatus {
                                    postBubbleVM.post.voteStatus = voteStatus
                                } else if let error = postResponseBody.error {
                                    print("DEBUG: \(error)")
                                }
                            case .failure(let error):
                                print("DEBUG: postBubbleVM.postVote error: \(error)")
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                } else if postBubbleVM.post.voteStatus == 1 {
                    // if upvoted
                    Button {
                        postBubbleVM.postVote(direction: 1) { result in
                            switch result {
                            case .success(let postResponseBody):
                                if let voteStatus = postResponseBody.voteStatus {
                                    postBubbleVM.post.voteStatus = voteStatus
                                } else if let error = postResponseBody.error {
                                    print("DEBUG: \(error)")
                                }
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
                        Text("\(postBubbleVM.post.score + 1)")
                    }
                    
                    Button {
                        postBubbleVM.postVote(direction: -1) { result in
                            switch result {
                            case .success(let postResponseBody):
                                if let voteStatus = postResponseBody.voteStatus {
                                    postBubbleVM.post.voteStatus = voteStatus
                                } else if let error = postResponseBody.error {
                                    print("DEBUG: \(error)")
                                }
                            case .failure(let error):
                                print("DEBUG: postBubbleVM.postVote error: \(error)")
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                } else if postBubbleVM.post.voteStatus == -1 {
                    // if downvoted
                    Button {
                        postBubbleVM.postVote(direction: 1) { result in
                            switch result {
                            case .success(let postResponseBody):
                                if let voteStatus = postResponseBody.voteStatus {
                                    postBubbleVM.post.voteStatus = voteStatus
                                } else if let error = postResponseBody.error {
                                    print("DEBUG: \(error)")
                                }
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
                        Text("\(postBubbleVM.post.score - 1)")
                    }
                    
                    Button {
                        postBubbleVM.postVote(direction: -1) { result in
                            switch result {
                            case .success(let postResponseBody):
                                if let voteStatus = postResponseBody.voteStatus {
                                    postBubbleVM.post.voteStatus = voteStatus
                                } else if let error = postResponseBody.error {
                                    print("DEBUG: \(error)")
                                }
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
                        Text("\(postBubbleVM.post.score)")
                            .foregroundColor(.green)
                        Text("\(postBubbleVM.post.score)")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .frame(width: 15, height: 50)
    }
}



//struct PostBubbleView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostBubble(post: defaultPost, postSettingsVM: PostSettingsViewModel(), feedVM: FeedViewModel())
//    }
//}
