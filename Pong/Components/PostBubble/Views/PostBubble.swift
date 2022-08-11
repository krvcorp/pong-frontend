import SwiftUI

struct PostBubble: View {
    @Binding var post : Post
    @StateObject var postBubbleVM = PostBubbleViewModel()
    @ObservedObject var postSettingsVM : PostSettingsViewModel
    
    // MARK: Some local view logic
    @State private var showScore = false
    @State private var sheet = false
    
    var body: some View {
        VStack {
            NavigationLink(destination: PostView(post: $post)) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("\(postBubbleVM.post.timeSincePosted)")
                            .font(.caption)
                            .padding(.bottom, 4)
          
                        Text(postBubbleVM.post.title)
                            .multilineTextAlignment(.leading)
                        
//                        if let imageUrl = postBubbleVM.post.image {
//                            AsyncImage(url: URL(string: "https://a11d-2600-4040-49e9-4700-18f-f080-a04a-f3ee.ngrok.io" + imageUrl)) { image in
//                                VStack {
//                                    image.resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                }
//                            } placeholder: {
//                                VStack {
//                                    ProgressView()
//                                }
//                            }
//                        }
                    }
                    .padding(.bottom)
                    
                    Spacer()
                    
                    VoteComponent
                }
                .background(Color(UIColor.tertiarySystemBackground))

            }

            Color.black.frame(height:CGFloat(1) / UIScreen.main.scale)

            HStack {
                NavigationLink(destination: PostView(post: $post)) {
                    HStack {
                        Image(systemName: "bubble.left")
                        Text("\(postBubbleVM.post.numComments)")
                            .font(.subheadline).bold()

                        Spacer()
                    }
                    .background(Color(UIColor.tertiarySystemBackground))
                }
                
                Button {
                    sheet.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .sheet(isPresented: $sheet) {
                    ShareSheet(items: ["ponged: \(postBubbleVM.post.title)"])
                }
                
                // MARK: Delete or More Button
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
                    Menu {
                        Button {
                            print("DEBUG: Save")
                        } label: {
                            Label("Save", systemImage: "bookmark")
                        }
                        
                        Button {
                            print("DEBUG: Block")
                        } label: {
                            Label("Block user", systemImage: "x.circle")
                        }
                        
                        Button {
                            print("DEBUG: Report")
                        } label: {
                            Label("Report", systemImage: "flag")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .frame(width: 30, height: 30)
                    }
                    .frame(width: 25, height: 25)
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
        .onAppear {
            postBubbleVM.post = self.post
        }
        .onChange(of: postBubbleVM.post) {
            self.post = $0
        }
        
        // MARK: Delete Confirmation
        .alert(isPresented: $postSettingsVM.showDeleteConfirmationView) {
            Alert(
                title: Text("Delete post"),
                message: Text("Are you sure you want to delete \(postSettingsVM.post.title)"),
                primaryButton: .default(
                    Text("Cancel")
                ),
                secondaryButton: .destructive(
                    Text("Delete"),
                    action: postSettingsVM.deletePost
                )
            )
        }
    }
    
    var VoteComponent: some View {
        VStack {
            if !showScore {
                // if not upvoted or downvoted
                if postBubbleVM.post.voteStatus == 0 {
                    Button {
                        postBubbleVM.postVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    
                    Button {
                        withAnimation {
                            showScore.toggle()
                        }

                    } label: {
                        Text("\(postBubbleVM.post.score)")
                    }
                    
                    Button {
                        postBubbleVM.postVote(direction: -1)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                } else if postBubbleVM.post.voteStatus == 1 {
                    // if upvoted
                    Button {
                        postBubbleVM.postVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.yellow)
                    }
                    
                    Button {
                        withAnimation {
                            showScore.toggle()
                        }

                    } label: {
                        Text("\(postBubbleVM.post.score + 1)")
                    }
                    
                    Button {
                        postBubbleVM.postVote(direction: -1)
                    } label: {
                        Image(systemName: "arrow.down")
                    }
                }
                // IF POST BUBBLE IS DOWNVOTES
                else if postBubbleVM.post.voteStatus == -1 {
                    // upvote
                    Button {
                        postBubbleVM.postVote(direction: 1)
                    } label: {
                        Image(systemName: "arrow.up")
                    }
                    
                    // score
                    Button {
                        withAnimation {
                            showScore.toggle()
                        }
                    } label: {
                        Text("\(postBubbleVM.post.score - 1)")
                    }
                    
                    // downvote
                    Button {
                        postBubbleVM.postVote(direction: -1)
                    } label: {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.yellow)
                    }
                }
            } else {
                Button {
                    withAnimation {
                        showScore.toggle()
                    }

                } label: {
                    VStack {
                        if postBubbleVM.post.voteStatus == 1 {
                            Text("\(postBubbleVM.post.numUpvotes + 1)")
                                .foregroundColor(.green)
                            Text("\(postBubbleVM.post.numDownvotes)")
                                .foregroundColor(.red)
                        }
                        else if postBubbleVM.post.voteStatus == -1 {
                            Text("\(postBubbleVM.post.numUpvotes)")
                                .foregroundColor(.green)
                            Text("\(postBubbleVM.post.numDownvotes + 1)")
                                .foregroundColor(.red)
                        }
                        else if postBubbleVM.post.voteStatus == 0 {
                            Text("\(postBubbleVM.post.numUpvotes)")
                                .foregroundColor(.green)
                            Text("\(postBubbleVM.post.numDownvotes)")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .frame(width: 25, height: 50)
    }
}



//struct PostBubbleView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostBubble(post: defaultPost, postSettingsVM: PostSettingsViewModel(), feedVM: FeedViewModel())
//    }
//}
