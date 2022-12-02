import SwiftUI
import AlertToast
import MapKit
import Kingfisher
import ActivityIndicatorView

struct PostView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataManager = DataManager.shared
    
    @Binding var post : Post
    @StateObject var postVM = PostViewModel()
    @ObservedObject private var notificationsManager = NotificationsManager.shared
    
    // local variables
    @State private var text = ""
    @State var sheet = false
    @State private var showScore = false
    @FocusState private var textIsFocused : Bool
    @State private var showSheet = false
    
    // loading comments
    @State var isLoading = true
    
    // conversation
    @State var isLinkActive = false
    @State var conversation = defaultConversation
    
    @State var uiTabarController: UITabBarController?

    @State var scrollToTop = false
    
    // MARK: Body
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                List {
                    // MARK: Post itself
                    VStack {
                        postMainTop
                            .padding(.horizontal)
                        
                        mainPost
                            .frame(width: UIScreen.screenWidth)
                        
                        bottomRow
                            .padding(.horizontal)
                            .padding(.top)
                    }
                    .id("top")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.pongSystemBackground)
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(PlainButtonStyle())
                    .toast(isPresenting: $postVM.savedPostConfirmation) {
                        AlertToast(type: .regular, title: "Post saved!")
                    }
                    .padding(.vertical, 5)
                    
                    // MARK: Comments
                    if isLoading {
                        loadingComponent
                            .listRowBackground(Color.pongSecondarySystemBackground)
                    }
                    else {
                        if let index = dataManager.postComments.firstIndex(where: {$0.0 == post.id}) {
                            if dataManager.postComments[index].1 != [] {
                                ForEach($dataManager.postComments[index].1, id: \.id) { $comment in
                                    CustomListDivider()
                                    
                                    CommentBubble(comment: $comment, isLinkActive: $isLinkActive, conversation: $conversation)
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.bottom, 10)
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.pongSystemBackground)
                                }
                                .listRowInsets(EdgeInsets())
                            } else {
                                Button {
                                    self.textIsFocused = true
                                } label: {
                                    HStack {
                                        Spacer()
                                        
                                        Text("No comments yet. Let the world know what you think.")
                                            .bold()
                                            .font(.system(size: 10))
                                            .foregroundColor(Color.pongSecondaryText)
                                        
                                        Spacer()
                                    }
                                    .frame(minHeight: 100)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.pongSecondarySystemBackground)
                            }
                        }
                    }
                    
                    
                    // MARK: Rectangle to allow for more scrolling space
                    Rectangle()
                        .fill(Color.pongSecondarySystemBackground)
                        .listRowBackground(Color.pongSecondarySystemBackground)
                        .frame(minHeight: 150)
                        .listRowSeparator(.hidden)
                }
                .scrollContentBackgroundCompat()
                .background(Color.pongSecondarySystemBackground)
                .environment(\.defaultMinListRowHeight, 0)
                .listStyle(PlainListStyle())
                .refreshable {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        // API call to refresh local data
                        postVM.readPost(post: post, dataManager: dataManager) { result in
                            if !result {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                        
                        // API call to fetch comments to display
                        postVM.getComments() { successResponse in
                            if let index = dataManager.postComments.firstIndex(where: {$0.0 == post.id}) {
                                dataManager.postComments[index] = (post.id, successResponse)
                            }
                        }
                    }
                    await Task.sleep(500_000_000)
                }
                .onTapGesture {
                    hideKeyboard()
                    self.postVM.textIsFocused = false
                    self.textIsFocused = false
                }
                .onChange(of: scrollToTop) { newValue in
                    withAnimation {
                        proxy.scrollTo("top")
                    }
                }
            }
            
            // MARK: MessagingComponent
            messagingComponent()
                .background(Color.pongSystemBackground)
                .ignoresSafeArea(.all, edges: .bottom)
        }
        .background(Color.pongSystemBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar() {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: MessageView(conversation: $conversation), isActive: $isLinkActive) { EmptyView().opacity(0) }
                    .isDetailLink(false)
                    .opacity(0)
            }
        }
        .environmentObject(postVM)
        .onAppear {
            if dataManager.postComments.firstIndex(where: {$0.0 == post.id}) == nil {
                DispatchQueue.main.async {
                    // take binding and insert into VM
                    postVM.post = self.post
                    
                    // API call to append post.id, comment tuple into DataManager.postComments
                    postVM.getComments() { successResponse in
                        dataManager.postComments.append((post.id, successResponse))
                        isLoading = false
                    }
                }
            }
            else {
                isLoading = false
            }
        }
        // MARK: OnChange Stuff
        .onChange(of: self.post.id, perform: { newValue in
            DispatchQueue.main.async {
                print("DEBUG: self.post.id.onChange")
                postVM.post = self.post
                postVM.getComments() { successResponse in
                    if dataManager.postComments.firstIndex(where: {$0.0 == post.id}) == nil {
                        DispatchQueue.main.async {
                            postVM.post = self.post
                            dataManager.postComments.append((post.id, successResponse))
                            
                        }
                    }
                }
            }
        })
        .onChange(of: postVM.postUpdateTrigger) { newValue in
            DispatchQueue.main.async {
                if postVM.post.id != "default" {
                    self.post = postVM.post
                    dataManager.updatePostLocally(post: postVM.post)
                }
            }
        }
        .onChange(of: postVM.commentUpdateTrigger) { newValue in
            DispatchQueue.main.async {
                if postVM.post.id != "default" {
                    self.post = postVM.post
                }
            }
            dataManager.updatePostLocally(post: postVM.post)
        }
        // MARK: Alerts and Toasts
        .alert(isPresented: $postVM.showConfirmation) {
            switch postVM.activeAlert {
            case .postDelete:
                return Alert(
                    title: Text("Delete post"),
                    message: Text("Are you sure you want to delete \"\(post.title)\""),
                    primaryButton: .destructive(Text("Delete")) {
                        postVM.deletePost(post: post, dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )
            case .postReport:
                return Alert(
                    title: Text("Report post"),
                    message: Text("Are you sure you want to report \"\(post.title)\""),
                    primaryButton: .destructive(Text("Report")) {
                        postVM.reportPost(post: post, dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )
            case .postBlock:
                return Alert(
                    title: Text("Block post and user"),
                    message: Text("Are you sure you want to block content from this user?"),
                    primaryButton: .destructive(Text("Block")) {
                        postVM.blockPost(post: post, dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )
            case .commentDelete:
                return Alert(
                    title: Text("Delete comment"),
                    message: Text("Are you sure you want to delete \"\(postVM.commentToDelete.comment)\""),
                    primaryButton: .destructive(Text("Delete")) {
                        postVM.deleteCommentConfirm(post: post, dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )
            case .commentReport:
                return Alert(
                    title: Text("Report comment"),
                    message: Text("Are you sure you want to report \"\(postVM.commentToDelete.comment)\""),
                    primaryButton: .destructive(Text("Report")) {
                        postVM.reportCommentConfirm(post: post, dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )
            case .commentBlock:
                return Alert(
                    title: Text("Block comment"),
                    message: Text("Are you sure you want to block content from this user?"),
                    primaryButton: .destructive(Text("Block")) {
                        postVM.blockCommentConfirm(post: post, dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    var loadingComponent: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                ProgressView()
                    .foregroundColor(Color.pongLabel)
                
                Spacer()
            }
            Spacer()
        }
    }
    
    // MARK: MainPost
    var mainPost: some View {
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
    
    // MARK: PostMainTop
    /// Top row of the post
    var postMainTop: some View {
        VStack {
            HStack {
                Text("\(post.timeSincePosted) ago")
                    .font(.caption)
                    .foregroundColor(Color.pongSecondaryText)
                    .padding(.bottom, 2)
                
                Spacer()
                
                if !post.userOwned {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.post = post
                        postVM.startConversation(post: post, dataManager: dataManager) { success in
                            conversation = success
                            isLinkActive = true
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image("bubble.dots.left")
                            
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
                            postVM.post = post
                            postVM.activeAlert = .postBlock
                            postVM.showConfirmation = true
                        } label: {
                            Label("Block user", systemImage: "x.circle")
                        }
                        
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            postVM.post = post
                            postVM.activeAlert = .postReport
                            postVM.showConfirmation = true
                        } label: {
                            Label("Report", systemImage: "flag")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .frame(width: 30, height: 30)
                    }
                    .frame(width: 25, height: 25)
                    .foregroundColor(Color.pongSecondaryText)
                }
            }
            
            if let tagName = post.tag {
                HStack {
                    Text(Tag(rawValue: tagName)!.title!.uppercased())
                        .font(.system(size: 16))
                        .fontWeight(.heavy)
                        .foregroundColor(Tag(rawValue: tagName)!.color)
                    Spacer()
                }
                .padding(.bottom, 3)
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
    
    // MARK: BottomRow
    /// Note that the .frame(maxWidth: .infinity) allows the three columns of the bottom row to each be equal sizes
    var bottomRow: some View {
        HStack(spacing: 0) {
            
            voteComponent
                .frame(minWidth: 0, maxWidth: .infinity)
            
            HStack {
                Image("bubble.left")
                    .foregroundColor(Color.pongSecondaryText)
                
                Text("\(post.numComments)")
                    .bold()
                    .foregroundColor(Color.pongSecondaryText)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            
            
            HStack {
                Spacer()
                if !post.userOwned {
                    
                    if post.saved {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            postVM.post = post
                            postVM.unsavePost(post: post, dataManager: dataManager)
                        } label: {
                            Image("bookmark.fill")
                                .foregroundColor(Color.pongAccent)
                        }
                    } else if !post.saved {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            postVM.post = post
                            postVM.savePost(post: post, dataManager: dataManager)
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
                            postVM.post = post
                            postVM.activeAlert = .postDelete
                            postVM.showConfirmation = true
                        }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(Color.pongSecondaryText)
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .font(.title3)
    }
    
    // MARK: VoteComponent
    var voteComponent: some View {
        HStack {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                postVM.postVote(direction: 1, post: post, dataManager: dataManager)
            } label: {
                Text(Image(systemName: "arrow.up"))
                    .foregroundColor(post.voteStatus == 1 ? Color.pongAccent : Color.pongSecondaryText)
                    .fontWeight(.bold)
            }
            
            Text("\(voteTruncate(votes: post.score + post.voteStatus))")
                .foregroundColor(post.voteStatus != 0 ? Color.pongAccent : Color.pongSecondaryText)
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                postVM.postVote(direction: -1, post: post, dataManager: dataManager)
            } label: {
                Text(Image(systemName: "arrow.down"))
                    .foregroundColor(post.voteStatus == -1 ? Color.pongAccent : Color.pongSecondaryText)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
    }
    
    // MARK: Overlay component to create a comment or reply
    @ViewBuilder
    func messagingComponent() -> some View {
        VStack(spacing: 0) {
            // MARK: Messaging Component
            VStack {
                // MARK: Reply to Component
                if postVM.replyToComment != defaultComment {
                    HStack {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            postVM.replyToComment = defaultComment
                            text = ""
                        } label: {
                            Image(systemName: "xmark")
                        }

                        Text("Replying to: ").font(.subheadline) + Text("\(postVM.replyToComment.comment)").font(.subheadline.bold())
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                }
                // MARK: TextArea and Button Component
                VStack {
                    
                    // MARK: Image
                    HStack {
                        if postVM.commentImage != nil {
                            ZStack(alignment: .topLeading) {
                                Image(uiImage: self.postVM.commentImage!)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    postVM.commentImage = nil
                                } label: {
                                    Image("trash")
                                }
                                .frame(width: 35, height: 35)
                                .foregroundColor(.white)
                                .background(Circle().fill(.black).opacity(0.6))
                                .padding()
                            }
                            .frame(maxWidth: UIScreen.screenWidth / 1.25, maxHeight: UIScreen.screenHeight / 5)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            .padding(1)
                        }
                        
                        Spacer()
                    }
                    .padding(1)
                    
                    // MARK: Comment Overlay
                    HStack() {
                        // MARK: Image Button
//                        Button {
//                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                            showSheet = true
//                        } label: {
//                            ZStack {
//                                Image(systemName: "photo")
//                                    .imageScale(.small)
//                                    .foregroundColor(Color(UIColor.label))
//                                    .font(.largeTitle)
//                            }
//                            .frame(width: 30, height: 40, alignment: .center)
//                            .cornerRadius(10)
//                        }
//                        .sheet(isPresented: $showSheet) {
//                            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$postVM.commentImage)
//                        }
                        
                        // MARK: TextField
                        HStack {
                            TextField("Join the conversation...", text: $text)
                                .font(.headline)
                                .focused($textIsFocused)
                                .onChange(of: postVM.textIsFocused) {
                                    self.textIsFocused = $0
                                }
                        }
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(20)
                            
                        // MARK: PaperPlane
                        if text != "" || postVM.commentImage != nil {
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                if postVM.replyToComment == defaultComment {
                                    postVM.createComment(post: post, comment: text, dataManager: dataManager, notificationsManager: notificationsManager) { success in
                                        // resets stuff
                                        postVM.commentImage = nil
                                        text = ""
                                        withAnimation {
                                            textIsFocused = false
                                            postVM.textIsFocused = false
                                        }
                                        
                                        // add scroll to bottom here
                                        scrollToTop.toggle()
                                    }
                                } else {
                                    postVM.commentReply(post: post, comment: text, dataManager: dataManager, notificationsManager: notificationsManager) { success in
                                        // resets stuff
                                        postVM.commentImage = nil
                                        text = ""
                                        withAnimation {
                                            textIsFocused = false
                                            postVM.textIsFocused = false
                                        }
                                    }
                                }

                            } label: {
                                ZStack {
                                    Image("paperplane.fill")
                                        .imageScale(.large)
                                        .foregroundColor(Color.pongAccent)
                                }
                                .frame(width: 30, height: 40, alignment: .center)
                                .cornerRadius(10)
                            }
                        } else {
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            } label: {
                                ZStack {
                                    Image("paperplane.fill")
                                        .imageScale(.large)
                                        .foregroundColor(Color.pongAccent).opacity(0.25)
                                }
                                .frame(width: 30, height: 40, alignment: .center)
                                .cornerRadius(10)
                            }
                            .disabled(true)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 3)    
            }
        }
    }
}
