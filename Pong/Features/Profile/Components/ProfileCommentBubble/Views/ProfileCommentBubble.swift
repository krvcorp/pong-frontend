import SwiftUI
import AlertToast
import Kingfisher

struct ProfileCommentBubble: View {
    @Binding var comment : ProfileComment
    
    @StateObject var profileCommentBubbleVM = ProfileCommentBubbleViewModel()
    @EnvironmentObject var dataManager : DataManager
    
    @State private var sheet = false
    @State private var image = UIImage()
    
    // MARK: Body
    var body: some View {
        ZStack {
            NavigationLink(destination: PostView(post: $profileCommentBubbleVM.parentPost)) {
                EmptyView()
            }
            .opacity(0.0)
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading) {
                // MARK: Body
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(comment.timeSincePosted) ago • On: \(comment.re)")
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundColor(Color.pongSecondaryText)
                        
                        Spacer()
                    }
                    .padding(.bottom, 2)
                    
                    Text(comment.comment)
                        .lineLimit(2)
                    
                    HStack {
                        if let imageUrl = comment.image {
                            KFImage(URL(string: "\(imageUrl)")!)
                                .resizable()
                                .scaledToFit()
                                .frame(idealWidth: abs(UIScreen.screenWidth / 1.1), idealHeight: abs(CGFloat(comment.imageHeight!) * (UIScreen.screenWidth / 1.1) / CGFloat(comment.imageWidth!)), maxHeight: abs(CGFloat(150)))
                                .padding(.top)
                        }
                    }
                }
                .padding(.bottom)
                
                // MARK: Bottom Row
                HStack(spacing: 0) {
                    voteComponent
                        .frame(minWidth: 0, maxWidth: .infinity)
                    
                    HStack {
                        Spacer()
                        
                        // MARK: Delete or More Button
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            DispatchQueue.main.async {
                                profileCommentBubbleVM.showDeleteConfirmationView.toggle()
                            }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(Color("pongSecondaryText"))
                        }
                    }
                }
                .font(.headline)
            }
        }
        .font(.system(size: 18).bold())
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
    
    // MARK: VoteComponent
    var voteComponent: some View {
        HStack {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                profileCommentBubbleVM.commentVote(direction: 1, dataManager: dataManager)
            } label: {
                Text(Image(systemName: "arrow.up"))
                    .foregroundColor(comment.voteStatus == 1 ? Color.pongAccent : Color.pongSecondaryText)
                    .fontWeight(.bold)
            }
            
            Text("\(comment.score + comment.voteStatus)")
                .foregroundColor(Color.pongSecondaryText)
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                profileCommentBubbleVM.commentVote(direction: -1, dataManager: dataManager)
            } label: {
                Text(Image(systemName: "arrow.down"))
                    .foregroundColor(comment.voteStatus == -1 ? Color.pongAccent : Color.pongSecondaryText)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
    }
}


