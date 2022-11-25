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
    
    // conversation
    @State private var isLinkActive = false
    @State private var conversation = defaultConversation
    
    var body: some View {
        VStack() {
            postBubbleTop
                .padding(.horizontal)
            
            postBubbleMain
                .frame(width: UIScreen.screenWidth)
            
            postBubbleBottomRow
                .padding(.horizontal)
        }
        .padding(.vertical, 10)
        
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
    
    // MARK: PostBubbleTop
    var postBubbleTop: some View {
        VStack {
            HStack {
                if (post.timeSincePosted == "Now") {
                    Text("\(post.timeSincePosted)")
                        .font(.caption)
                        .foregroundColor(Color.pongSecondaryText)
                        .padding(.bottom, 2)
                } else {
                    Text("\(post.timeSincePosted) ago")
                        .font(.caption)
                        .foregroundColor(Color.pongSecondaryText)
                        .padding(.bottom, 2)
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
                        HStack(spacing: 3) {
                            Image("bubble.dots.center.fill")
                            
                            Text("Message")
                        }
                        .font(.subheadline.bold())
                        .padding(.vertical, 5)
                        .padding(.horizontal, 5)
                        .foregroundColor(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke().foregroundColor(Color.pongAccent))
                        .background(Color.pongAccent)
                        .cornerRadius(15)
                    }
                    
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
                    .foregroundColor(Color.pongLabel)
                }
            }
            
            if let tagName = post.tag {
                HStack {
                    Text(Tag(rawValue: tagName)!.title!)
                        .padding(1)
                        .padding(.horizontal)
                        .foregroundColor(Color(UIColor.systemBackground))
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Tag(rawValue: tagName)!.color, lineWidth: 2))
                        .background(Tag(rawValue: tagName)!.color)
                        .cornerRadius(15)         // You also need the cornerRadius here
                        .padding(.bottom)
                    Spacer()
                }
                .padding(0)
            }
            
            HStack() {
                Text(post.title)
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
        }
    }
    
    // MARK: PostBubbleMain
    var postBubbleMain: some View {
        ZStack {
            NavigationLink(destination: MessageView(conversation: $conversation), isActive: $isLinkActive) { EmptyView().opacity(0) }
                .isDetailLink(false)
                .opacity(0)
                .disabled(true)
            
            NavigationLink(destination: PostView(post: $post)) {
                EmptyView()
            }
            .opacity(0.0)
            .buttonStyle(PlainButtonStyle())
            
            VStack (alignment: .leading) {
                // MARK: Image
                if let imageUrl = post.image {
                    KFImage(URL(string: "\(imageUrl)")!)
                        .resizable()
                        .scaledToFit()
                        .frame(idealWidth: abs(UIScreen.screenWidth), idealHeight: abs(CGFloat(post.imageHeight!) * (UIScreen.screenWidth) / CGFloat(post.imageWidth!)), maxHeight: abs(CGFloat(300)))
                }
                
                // MARK: Poll
                if post.poll != nil && post.image == nil {
                    PollView(post: $post)
                }
            }
        }
    }
    
    // MARK: PostBubbleBottomRow
    /// Note that the .frame(maxWidth: .infinity) allows the three columns of the bottom row to each be equal sizes
    var postBubbleBottomRow: some View {
        HStack(spacing: 0) {
            
            voteComponent
                .frame(minWidth: 0, maxWidth: .infinity)
            
            HStack {
                Image("bubble.left")
                    .foregroundColor(Color("pongSecondaryText"))
                Text("\(post.numComments)")
                    .bold()
                    .foregroundColor(Color("pongSecondaryText"))
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            
            
            HStack() {
                Spacer()
                if !post.userOwned {
                    
                    if post.saved {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            postBubbleVM.post = post
                            postBubbleVM.unsavePost(post: post, dataManager: dataManager)
                        } label: {
                            Image("bookmark.fill")
                                .foregroundColor(Color.pongAccent)
                        }
                    } else if !post.saved {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            postBubbleVM.post = post
                            postBubbleVM.savePost(post: post, dataManager: dataManager)
                        } label: {
                            Image("bookmark")
                                .foregroundColor(Color.pongSecondaryText)
                        }
                    }
                }
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    sheet.toggle()
                } label: {
                    // wrapping the image in a text so we can set font weight without having to set a font size as well
                    Text(Image("share"))
                        .fontWeight(.medium)
                        .foregroundColor(Color.pongSecondaryText)
                }
                .sheet(isPresented: $sheet) {
                    ShareSheet(items: ["\(NetworkManager.networkManager.rootURL)post/\(post.id)/"])
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
                        Image("trash")
                            .foregroundColor(Color.pongSecondaryText)
                    }
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .font(.title3)
    }
    
    // MARK: VoteComponent
    var voteComponent: some View {
        HStack {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                postBubbleVM.postVote(direction: 1, post: post, dataManager: dataManager)
            } label: {
                Text(Image(systemName: "arrow.up"))
                    .foregroundColor(post.voteStatus == 1 ? Color.pongAccent : Color.pongSecondaryText)
                    .fontWeight(.bold)
            }
            
            Text("\(post.score + post.voteStatus)")
                .foregroundColor(Color.pongSecondaryText)
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                postBubbleVM.postVote(direction: -1, post: post, dataManager: dataManager)
            } label: {
                Text(Image(systemName: "arrow.down"))
                    .foregroundColor(post.voteStatus == -1 ? Color.pongAccent : Color.pongSecondaryText)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
    }
}
