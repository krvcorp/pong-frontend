import SwiftUI
import AlertToast
import MapKit
import Kingfisher
import ActivityIndicatorView

struct PostView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var mainTabVM : MainTabViewModel
    @StateObject var dataManager = DataManager.shared
    
    @Binding var post : Post
    @StateObject var postVM = PostViewModel()
    @ObservedObject private var notificationsManager = NotificationsManager.notificationsManager
    
    // local variables
    @State private var text = ""
    @State var sheet = false
    @State private var showScore = false
    @FocusState private var textIsFocused : Bool
    @State private var showSheet = false
    
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
                        mainPost
                            .toast(isPresenting: $postVM.savedPostConfirmation) {
                                AlertToast(type: .regular, title: "Post saved!")
                            }
                            .padding()
                            .font(.system(size: 18).bold())
                        
                        bottomRow
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                    }
                    .id("top")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.pongSystemBackground)
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(PlainButtonStyle())
                    
                    // MARK: Comments
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
                                    
                                    Text("Start the discussion")
                                        .font(.title.bold())
                                    
                                    Spacer()
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.pongSystemBackground)
                                .frame(minHeight: 100)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    Rectangle()
                        .fill(Color.pongSystemBackground)
                        .listRowBackground(Color.pongSystemBackground)
                        .frame(minHeight: 150)
                        .listRowSeparator(.hidden)
                }
                .scrollContentBackgroundCompat(.hidden)
                .background(Color.pongSystemBackground)
                .environment(\.defaultMinListRowHeight, 0)
                .listStyle(PlainListStyle())
                .refreshable {
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
        }
        .background(Color.pongSystemBackground)
        .environmentObject(postVM)
        .onAppear {
            if dataManager.postComments.firstIndex(where: {$0.0 == post.id}) == nil {
                DispatchQueue.main.async {
                    // take binding and insert into VM
                    postVM.post = self.post
                    
                    // API call to append post.id, comment tuple into DataManager.postComments
                    postVM.getComments() { successResponse in
                        dataManager.postComments.append((post.id, successResponse))
                    }
                }
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
                    print("DEBUG: postVM.postUpdateTrigger.onChange")
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
        .onChange(of: mainTabVM.scrollToTop, perform: { newValue in
            DispatchQueue.main.async {
                self.presentationMode.wrappedValue.dismiss()
            }
        })
        .onChange(of: mainTabVM.newPostDetected, perform: { newValue in
            DispatchQueue.main.async {
                self.presentationMode.wrappedValue.dismiss()
            }
        })
        .navigationBarTitleDisplayMode(.inline)
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
        .toast(isPresenting: $dataManager.removedComment) {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: dataManager.removedCommentMessage)
        }
    }
    
    // MARK: MainPost
    var mainPost: some View {
        VStack {
            HStack {
                VStack {
                    HStack {
                        Text("\(post.timeSincePosted) ago")
                            .font(.caption)
                            .foregroundColor(Color(UIColor.systemGray))
                            .padding(.bottom, 3)
                        Spacer()
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
                            .bold()
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                }
                
                voteComponent
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
    
    // MARK: BottomRow
    var bottomRow: some View {
        HStack {
            if !post.userOwned {
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
                .foregroundColor(Color(UIColor.gray))
            }
            
            Spacer()
            
            if !post.userOwned {
                NavigationLink(destination: MessageView(conversation: $conversation), isActive: $isLinkActive) { EmptyView().opacity(0) }.opacity(0)
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postVM.startConversation(post: post, dataManager: dataManager) { success in
                        conversation = success
                        isLinkActive = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "envelope")
                            .font(.headline.bold())
                        Text("DM")
                            .bold()
                            .padding(.leading, -5)
                    }
                    .foregroundColor(Color(UIColor.gray))
                    
                }
                
                if post.saved {
                    Button {
                        print("DEBUG: button tap")
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.post = post
                        postVM.unsavePost(post: post, dataManager: dataManager)
                    } label: {
                        Image(systemName: "bookmark.fill")
                            .font(.headline.bold())
                            .foregroundColor(Color(UIColor.gray))
                    }
                } else if !post.saved {
                    Button {
                        print("DEBUG: button tap")
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        postVM.post = post
                        postVM.savePost(post: post, dataManager: dataManager)
                    } label: {
                        Image(systemName: "bookmark")
                            .font(.headline.bold())
                            .foregroundColor(Color(UIColor.gray))
                    }
                }
            }
            
            // MARK: Delete button
            else {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    DispatchQueue.main.async {
                        postVM.post = post
                        postVM.activeAlert = .postDelete
                        postVM.showConfirmation = true
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(Color(UIColor.gray))
                        .font(.headline.bold())
                }
            }
        }
    }
    
    // MARK: VoteComponent
    var voteComponent: some View {
        VStack {
            if post.voteStatus == 0 {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postVM.postVote(post: post, direction: 1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.up")
                        .foregroundColor(Color(UIColor.gray))
                        .font(.headline)
                }
                
                Text("\(post.score)")
                    .bold()
                    .font(.system(size: 18).bold())
                    .foregroundColor(Color(UIColor.gray))
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postVM.postVote(post: post, direction: -1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(UIColor.gray))
                        .font(.headline)
                }
            } else if post.voteStatus == 1 {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postVM.postVote(post: post, direction: 1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.up")
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                        .font(.headline.bold())
                }
                
                Text("\(post.score + 1)")
                    .bold()
                    .font(.system(size: 18).bold())
                    .foregroundColor(Color(UIColor.gray))
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postVM.postVote(post: post, direction: -1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(UIColor.gray))
                        .font(.headline)
                }
            }
            else if post.voteStatus == -1 {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postVM.postVote(post: post, direction: 1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.up")
                        .foregroundColor(Color(UIColor.gray))
                        .font(.headline)
                }
                
                Text("\(post.score - 1)")
                    .bold()
                    .font(.system(size: 18).bold())
                    .foregroundColor(Color(UIColor.gray))
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    postVM.postVote(post: post, direction: -1, dataManager: dataManager)
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                        .font(.headline.bold())
                }
            }
        }
        .frame(width: 25, height: 80)

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
                    .padding(.top, 2)
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
                                    Image(systemName: "trash")
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
                    HStack {
                        HStack {
                            // Textfield
                            TextField("Add a comment", text: $text)
                                .font(.headline)
                                .focused($textIsFocused)
                                .onChange(of: postVM.textIsFocused) {
                                    self.textIsFocused = $0
                                }
                            
                            // Image Button
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                showSheet = true
                            } label: {
                                ZStack {
                                    Image(systemName: "photo")
                                        .imageScale(.small)
                                        .foregroundColor(Color(UIColor.label))
                                        .font(.largeTitle)
                                }
                                .frame(width: 30, height: 40, alignment: .center)
                                .cornerRadius(10)
                            }
                            .sheet(isPresented: $showSheet) {
                                ImagePicker(sourceType: .photoLibrary, selectedImage: self.$postVM.commentImage)
                            }
                            .padding(.trailing)
                                
                            // Paperplane Button
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
                                        Image(systemName: "paperplane")
                                            .imageScale(.small)
                                            .foregroundColor(Color(UIColor.label))
                                            .font(.largeTitle)
                                    }
                                    .frame(width: 30, height: 40, alignment: .center)
                                    .cornerRadius(10)
                                }
                            } else {
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                } label: {
                                    ZStack {
                                        Image(systemName: "paperplane")
                                            .imageScale(.small)
                                            .foregroundColor(Color(UIColor.quaternaryLabel))
                                            .font(.largeTitle)
                                    }
                                    .frame(width: 30, height: 40, alignment: .center)
                                    .cornerRadius(10)
                                }
                                .disabled(true)
                            }
                        }
                        .padding(5)
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(20)
                }
                .padding(.horizontal)
                .padding(.vertical, 3)    
            }
            .background(Color.pongSystemBackground)
            .cornerRadius(20, corners: [.topLeft, .topRight])
        }
        .shadow(color: Color(.black).opacity(0.3), radius: 10, x: 0, y: 0)
        .mask(Rectangle().padding(.top, -20))
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(post: .constant(defaultPost))
    }
}
