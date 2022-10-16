import SwiftUI
import AlertToast

struct ProfileCommentBubble: View {
    @Binding var comment : ProfileComment
    @StateObject var profileCommentBubbleVM = ProfileCommentBubbleViewModel()
    @EnvironmentObject var dataManager : DataManager
    
    // MARK: Some local view logic
    @State private var sheet = false
    @State private var image = UIImage()
    
    var body: some View {
        VStack {
            commentBubbleMain

            Color.black.frame(height:CGFloat(1) / UIScreen.main.scale)
            
            HStack {
                
                ZStack {
                    NavigationLink(destination: PostView(post: $profileCommentBubbleVM.parentPost)) {
                        EmptyView()
                    }
                    .opacity(0.0)
                    .buttonStyle(PlainButtonStyle())
                    
                    HStack {
                        Text("Re: \(comment.re)")
                            .font(.subheadline).bold()

                        Spacer()
                    }
                }

                
//                Button {
//                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                    self.image = handleShare()
//                    sheet.toggle()
//                } label: {
//                    Image(systemName: "square.and.arrow.up")
//                }
//                .sheet(isPresented: $sheet) {
//                    ShareSheet(items: ["\(NetworkManager.networkManager.rootURL)post/\(profileCommentBubbleVM.parentPost.id)/"])
//                }
                
                // MARK: Delete or More Button
                 
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    DispatchQueue.main.async {
                        profileCommentBubbleVM.showDeleteConfirmationView.toggle()
                    }
                } label: {
                    Image(systemName: "trash")
                }
                
            }
        }
        .font(.system(size: 18).bold())
        .padding(0)
        .padding(.top, 10)
        .alert(isPresented: $profileCommentBubbleVM.showDeleteConfirmationView) {
            Alert(
                title: Text("Delete comment"),
                message: Text("Are you sure you want to delete \"\(comment.comment)\""),
                primaryButton: .destructive(Text("Delete")) {
                    profileCommentBubbleVM.deleteComment(dataManager: dataManager)
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            DispatchQueue.main.async {
                profileCommentBubbleVM.comment = self.comment
                profileCommentBubbleVM.getParentPost()
            }
        }
        .onChange(of: profileCommentBubbleVM.commentUpdateTrigger) { change in
            print("DEBUG: old onChange self.comment.voteStatus \(self.comment.voteStatus)")
            print("DEBUG: new onChange VM.comment.voteStatus \(profileCommentBubbleVM.comment.voteStatus)")
            DispatchQueue.main.async {
                self.comment = profileCommentBubbleVM.comment
            }
        }
    }
    
    var commentBubbleMain: some View {
        ZStack {
            NavigationLink(destination: PostView(post: $profileCommentBubbleVM.parentPost)) {
                EmptyView()
            }
            .opacity(0.0)
            .buttonStyle(PlainButtonStyle())
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(comment.timeSincePosted)")
                        .font(.caption)
                        .padding(.bottom, 4)
      
                    Text(comment.comment)
                        .multilineTextAlignment(.leading)
                }
                .padding(.bottom)
                
                Spacer()
                
                VoteComponent
            }
        }
    }
    
    var VoteComponent: some View {
        HStack {
            if comment.voteStatus == 0 {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    profileCommentBubbleVM.commentVote(direction: 1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.up")
                        .foregroundColor(Color(UIColor.gray))
                }
                
                Text("\(comment.score)")
                    .foregroundColor(Color(UIColor.gray))
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    profileCommentBubbleVM.commentVote(direction: -1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(UIColor.gray))
                }
            } else if comment.voteStatus == 1 {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    profileCommentBubbleVM.commentVote(direction: 1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.up")
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                }
                
                Text("\(comment.score + 1)")
                    .foregroundColor(Color(UIColor.gray))
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    profileCommentBubbleVM.commentVote(direction: -1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(UIColor.gray))
                }
            }
            else if comment.voteStatus == -1 {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    profileCommentBubbleVM.commentVote(direction: 1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.up")
                        .foregroundColor(Color(UIColor.gray))
                }
                
                Text("\(comment.score - 1)")
                    .foregroundColor(Color(UIColor.gray))
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    profileCommentBubbleVM.commentVote(direction: -1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                }
            }
        }
    }
}
