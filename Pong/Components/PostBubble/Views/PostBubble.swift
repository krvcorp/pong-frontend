import SwiftUI
import AlertToast
import Kingfisher

struct PostBubble: View {
    @Binding var post : Post
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var mainTabVM: MainTabViewModel
    @StateObject var postBubbleVM = PostBubbleViewModel()
    
    // MARK: Some local view logic
    @State private var sheet = false
    @State private var image = UIImage()
    
    // MARK: Conversation
    @Binding var isLinkActive : Bool
    @Binding var conversation : Conversation
    
    var body: some View {
        VStack {
            PostBubbleMain
                .padding(.bottom)
            
            PostBubbleBottomRow
        }
        .font(.system(size: 18).bold())
        .padding(.top, 10)
        .padding(.leading, 15)
        .padding(.trailing, 15)
        
        // MARK: Binds the values of postVM.post and the binding Post passed down from Feed
        .onChange(of: postBubbleVM.updateTrigger) { newValue in
            DispatchQueue.main.async {
                self.post = postBubbleVM.post
            }
        }
        .toast(isPresenting: $postBubbleVM.savedPostConfirmation){
            AlertToast(type: .regular, title: "Post saved!")
        }
        // MARK: Delete/Block/Report Confirmation
        .alert(isPresented: $postBubbleVM.showConfirmation) {
            switch postBubbleVM.activeAlert {
            case .delete:
                return Alert(
                    title: Text("Delete post"),
                    message: Text("Are you sure you want to delete \"\(post.title)\""),
                    primaryButton: .destructive(Text("Delete")) {
                        postBubbleVM.deletePost(post: post, dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )

            case .report:
                return Alert(
                    title: Text("Report post"),
                    message: Text("Are you sure you want to report \"\(post.title)\""),
                    primaryButton: .destructive(Text("Report")) {
                        postBubbleVM.reportPost(post: post, dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )

            case .block:
                return Alert(
                    title: Text("Block post and user"),
                    message: Text("Are you sure you want to block posts from this user?"),
                    primaryButton: .destructive(Text("Block")) {
                        postBubbleVM.blockPost(post: post, dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    var PostBubbleMain: some View {
        ZStack {
            NavigationLink(destination: PostView(post: $post)) {
                EmptyView()
            }
            .opacity(0.0)
            .buttonStyle(PlainButtonStyle())
            
            VStack {
                HStack {
                    Text("\(post.timeSincePosted) ago")
                        .font(.caption)
                        .foregroundColor(Color(UIColor.systemGray))
                        .padding(.bottom, 3)
                    Spacer()
                    if !post.userOwned {
                        Menu {
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                postBubbleVM.post = post
                                postBubbleVM.activeAlert = .block
                                postBubbleVM.showConfirmation = true
                            } label: {
                                Label("Block user", systemImage: "x.circle")
                            }
                            
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                postBubbleVM.post = post
                                postBubbleVM.activeAlert = .report
                                postBubbleVM.showConfirmation = true
                            } label: {
                                Label("Report", systemImage: "flag")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .frame(width: 30, height: 30)
                        }
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color(UIColor.gray))
                    }
                }
                HStack() {
                    Text(post.title)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                        
                    Spacer()
                }
                
                // MARK: Image
                if let imageUrl = post.image {
                    KFImage(URL(string: "\(imageUrl)")!)
                        .resizable()
                        .scaledToFit()
                        .frame(idealWidth: abs(UIScreen.screenWidth / 1.1), idealHeight: abs(CGFloat(post.imageHeight!) * (UIScreen.screenWidth / 1.1) / CGFloat(post.imageWidth!)), maxHeight: abs(CGFloat(150)))
                        .cornerRadius(15)
                }
                
                // MARK: Poll
                if post.poll != nil && post.image == nil {
                    PollView(post: $post)
                }
            }
        }
    }
    
    var PostBubbleBottomRow: some View {
        HStack {
            
            VoteComponent
            
            Spacer()
            
            HStack {
                Image(systemName: "bubble.left")
                    .foregroundColor(Color(UIColor.gray))
                Text("\(post.numComments)")
                    .bold()
                    .foregroundColor(Color(UIColor.gray))
            }
            
            Spacer()
            
            if !post.userOwned {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postBubbleVM.post = post
                    postBubbleVM.startConversation(post: post, dataManager: dataManager) { success in
                        conversation = success
                        isLinkActive = true
                    }
                } label: {
                    Image(systemName: "envelope")
                        .foregroundColor(Color(UIColor.gray))
                }
                
                if post.saved {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postBubbleVM.post = post
                        postBubbleVM.unsavePost(post: post, dataManager: dataManager)
                    } label: {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(Color(UIColor.gray))
                    }
                } else if !post.saved {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postBubbleVM.post = post
                        postBubbleVM.savePost(post: post, dataManager: dataManager)
                    } label: {
                        Image(systemName: "bookmark")
                            .foregroundColor(Color(UIColor.gray))
                    }
                }
            }
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                self.image = handleShare()
                sheet.toggle()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(Color(UIColor.gray))
            }
            .sheet(isPresented: $sheet) {
                ShareSheet(items: [self.image])
            }
            
            // MARK: Delete or More Button
            if post.userOwned {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    DispatchQueue.main.async {
                        postBubbleVM.post = post
                        postBubbleVM.activeAlert = .delete
                        postBubbleVM.showConfirmation = true
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(Color(UIColor.gray))
                }
            }
        }
    }
    
    var VoteComponent: some View {
        HStack {
            if post.voteStatus == 0 {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postBubbleVM.postVote(direction: 1, post: post, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.up")
                        .foregroundColor(Color(UIColor.gray))
                }
                
                Text("\(post.score)")
                    .foregroundColor(Color(UIColor.gray))
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postBubbleVM.postVote(direction: -1, post: post, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(UIColor.gray))
                }
            } else if post.voteStatus == 1 {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postBubbleVM.postVote(direction: 1, post: post, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.up")
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                }
                
                Text("\(post.score + 1)")
                    .foregroundColor(Color(UIColor.gray))
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postBubbleVM.postVote(direction: -1, post: post, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(UIColor.gray))
                }
            }
            else if post.voteStatus == -1 {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postBubbleVM.postVote(direction: 1, post: post, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.up")
                        .foregroundColor(Color(UIColor.gray))
                }
                
                Text("\(post.score - 1)")
                    .foregroundColor(Color(UIColor.gray))
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postBubbleVM.postVote(direction: -1, post: post, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                }
            }
        }
    }
    
    func handleShare() -> UIImage {
        let imageSize: CGSize = CGSize(width: 500, height: 800)
        let highresImage = PostBubbleMain.asImage(size: imageSize)
        return highresImage
    }
}
