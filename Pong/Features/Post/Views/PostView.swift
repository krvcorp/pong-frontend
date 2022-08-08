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
    
    @State private var comment = ""
    @State var sheet = false
    @State private var showScore = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RefreshableScrollView {
                mainPost
                LazyVStack {
                    ForEach(postVM.comments, id: \.self) { comment in
                        HStack {
                            Spacer()
                            CommentBubble(comment: comment)
                        }
                    }
                }
                .padding(.bottom, 150)
            }
            .refreshable {
                print("DEBUG: Pull to refresh")
                postVM.readPost() { result in
                    switch result {
                    case .success(let post):
                        DispatchQueue.main.async {
                            postVM.post = post
                        }
                    case .failure(let error):
                        print("DEBUG: PostView readPost failure \(error)")
                    }
                }
                postVM.getComments()
            }
           
            HStack {
                CustomTextField(placeholder: Text("Enter your message here"), text: $comment)
                Button {
                    postVM.createComment(comment: comment) { result in
                        switch result {
                            case .success(let commentReturn):
                                print("DEBUG: \(commentReturn)")
                                postVM.post.numComments = postVM.post.numComments + 1
                            case .failure(let failure):
                                print("DEBUG: PostView createComment failure \(failure)")
                        }
                    }
                    comment = ""
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
        .onAppear {
            // take binding and insert into VM
            postVM.post = self.post
            
            // api call to refresh local data
            postVM.readPost { result in
                switch result {
                case .success(let post):
                    DispatchQueue.main.async {
                        postVM.post = post
                    }
                case .failure(let error):
                    print("DEBUG: postVM.readpost error \(error)")
                }
            }
            
            // api call to fetch comments to display
            postVM.getComments()
        }
        .onDisappear() {
            // prevent feedview from rebuilding but to update data
            print("DEBUG: PostView Disapear!")
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
                // if not upvoted or downvoted
                if postVM.post.voteStatus == 0 {
                    Button {
                        postVM.postVote(direction: 1) { result in
                            switch result {
                            case .success(let postResponseBody):
                                if let voteStatus = postResponseBody.voteStatus {
                                    postVM.post.voteStatus = voteStatus
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
                        Text("\(postVM.post.score)")
                    }
                    
                    Button {
                        postVM.postVote(direction: -1) { result in
                            switch result {
                            case .success(let postResponseBody):
                                if let voteStatus = postResponseBody.voteStatus {
                                    postVM.post.voteStatus = voteStatus
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
                } else if postVM.post.voteStatus == 1 {
                    // if upvoted
                    Button {
                        postVM.postVote(direction: 1) { result in
                            switch result {
                            case .success(let postResponseBody):
                                if let voteStatus = postResponseBody.voteStatus {
                                    postVM.post.voteStatus = voteStatus
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
                        Text("\(postVM.post.score + 1)")
                    }
                    
                    Button {
                        postVM.postVote(direction: -1) { result in
                            switch result {
                            case .success(let postResponseBody):
                                if let voteStatus = postResponseBody.voteStatus {
                                    postVM.post.voteStatus = voteStatus
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
                } else if postVM.post.voteStatus == -1 {
                    // if downvoted
                    Button {
                        postVM.postVote(direction: 1) { result in
                            switch result {
                            case .success(let postResponseBody):
                                if let voteStatus = postResponseBody.voteStatus {
                                    postVM.post.voteStatus = voteStatus
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
                        Text("\(postVM.post.score - 1)")
                    }
                    
                    Button {
                        postVM.postVote(direction: -1) { result in
                            switch result {
                            case .success(let postResponseBody):
                                if let voteStatus = postResponseBody.voteStatus {
                                    postVM.post.voteStatus = voteStatus
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
                        Text("\(postVM.post.score)")
                            .foregroundColor(.green)
                        Text("\(postVM.post.score)")
                            .foregroundColor(.red)
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
