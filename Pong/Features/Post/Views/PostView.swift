import SwiftUI
import AlertToast
import MapKit
import Kingfisher
import ActivityIndicatorView

struct PostView: View {    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var mainTabVM : MainTabViewModel
    @EnvironmentObject var dataManager: DataManager
    
    @Binding var post : Post
    @StateObject var postVM = PostViewModel()
    @ObservedObject private var notificationsManager = NotificationsManager.notificationsManager
    
    @State private var text = ""
    @State var sheet = false
    @State private var showScore = false
    @FocusState private var textIsFocused : Bool
    
//    images for comments
    @State private var showSheet = false
    
    // MARK: Conversation
    @State var isLinkActive = false
    @State var conversation = defaultConversation
    
    @State var didAppear = false
    @State var appearCount = 0
    
    @State var uiTabarController: UITabBarController?
    

    var body: some View {
        ZStack(alignment: .bottom) {
            RefreshableScrollView {
                HStack {
                    mainPost
                        .toast(isPresenting: $postVM.savedPostConfirmation) {
                            AlertToast(type: .regular, title: "Post saved!")
                        }
                        .padding(.top, 10)
                        .padding(.leading, 15)
                        .padding(.trailing, 15)
                        .padding(.bottom, 20)
                        .font(.system(size: 18).bold())
                }
                
                bottomRow
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                
                CustomListDivider()
                
                LazyVStack {
                    if let index = dataManager.postComments.firstIndex(where: {$0.0 == post.id}) {
                        ForEach($dataManager.postComments[index].1, id: \.self) { $comment in
                            CommentBubble(comment: $comment, isLinkActive: $isLinkActive, conversation: $conversation)
                                .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.bottom, 150)
            }
            .onTapGesture {
                hideKeyboard()
                self.postVM.textIsFocused = false
                self.textIsFocused = false
            }
            .refreshable {
                print("DEBUG: PostView refresh")
                // api call to refresh local data
                postVM.readPost(post: post, dataManager: dataManager) { result in
                    if !result {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                
                // api call to fetch comments to display
                postVM.getComments() { successResponse in
                    if let index = dataManager.postComments.firstIndex(where: {$0.0 == post.id}) {
                        dataManager.postComments[index] = (post.id, successResponse)
                    }
                }
            }
            
            MessagingComponent
        }
        .background(Color.pongSystemBackground)
        .environmentObject(postVM)
        .onAppear {
            debugPrint("DEBUG: ", dataManager.postComments)
            if dataManager.postComments.firstIndex(where: {$0.0 == post.id}) == nil {
                DispatchQueue.main.async {
                    // take binding and insert into VM
                    postVM.post = self.post
                    
                    // api call to refresh local data
                    //                postVM.readPost(dataManager: dataManager) { result in
                    //                    if !result {
                    //                        print("DEBUG: READ ERROR SHOULD DISMISS")
                    //                        self.presentationMode.wrappedValue.dismiss()
                    //
                    //                        // THIS IS IF DELETED
                    //                        dataManager.removePostLocally(post: post, message: "Post doesn't exist!")
                    //                    }
                    //                }
                    
                    // api call to fetch comments to display
                    postVM.getComments() { successResponse in
                        dataManager.postComments.append((post.id, successResponse))
                    }
                }
            }
        }
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
                        postVM.deleteCommentConfirm(dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )
            case .commentReport:
                return Alert(
                    title: Text("Report comment"),
                    message: Text("Are you sure you want to report \"\(postVM.commentToDelete.comment)\""),
                    primaryButton: .destructive(Text("Report")) {
                        postVM.deleteCommentConfirm(dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )
            case .commentBlock:
                return Alert(
                    title: Text("Block comment"),
                    message: Text("Are you sure you want to block content from this user?"),
                    primaryButton: .destructive(Text("Block")) {
                        postVM.deleteCommentConfirm(dataManager: dataManager)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .toast(isPresenting: $dataManager.removedComment) {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: dataManager.removedCommentMessage)
        }
    }
    
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
                VoteComponent
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
            }
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
            
            Spacer()
                
            
            if !post.userOwned {
                if post.saved {
                    Button {
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
            
//            Button {
//                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                self.image = handleShare()
//                sheet.toggle()
//            } label: {
//                Image(systemName: "square.and.arrow.up")
//                    .foregroundColor(Color(UIColor.gray))
//            }
//            .sheet(isPresented: $sheet) {
//                ShareSheet(items: [self.image])
//            }
            
            
        }
    }
    
    var VoteComponent: some View {
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
    var MessagingComponent: some View {
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
                            .frame(maxWidth: UIScreen.screenWidth / 1.25)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            .padding()
                        }
                        Spacer()
                    }
                    HStack {
                        TextField("Add a comment", text: $text)
                            .font(.headline)
                            .focused($textIsFocused)
                            .onChange(of: postVM.textIsFocused) {
                                self.textIsFocused = $0
                            }
                        
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
                            
                        if text != "" || postVM.commentImage != nil {
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                if postVM.replyToComment == defaultComment {
                                    postVM.createComment(post: post, comment: text, dataManager: dataManager, notificationsManager: notificationsManager)
                                } else {
                                    postVM.commentReply(comment: text, dataManager: dataManager, notificationsManager: notificationsManager)
                                    postVM.replyToComment = defaultComment
                                }
                                text = ""
                                withAnimation {
                                    textIsFocused = false
                                    postVM.textIsFocused = false
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
                        }
                    }
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 3)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.secondarySystemBackground), lineWidth: 2))
            }
            .background(Color(UIColor.secondarySystemBackground))
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
