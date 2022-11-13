import SwiftUI
import AlertToast

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var dataManager = DataManager.shared
    @StateObject private var profileVM = ProfileViewModel()
    
    @Namespace var namespace
    
    @State private var conversation = defaultConversation
    
    var body: some View {
        VStack {
            toolbarPickerComponent
            
            TabView(selection: $profileVM.selectedProfileFilter) {
                ForEach([ProfileFilter.posts, ProfileFilter.comments, ProfileFilter.about], id: \.self) { tab in
                    customProfileStack(filter: profileVM.selectedProfileFilter, tab: tab)
                        .tag(tab)
                        .background(Color.pongSystemBackground)
                }
            }
            .background(Color.pongSystemBackground)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .background(Color.pongSystemBackground)
        // Navigation bar
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .background(Color.pongSystemBackground)
        .accentColor(Color(UIColor.label))
        .navigationViewStyle(StackNavigationViewStyle())
        .toast(isPresenting: $dataManager.removedPost) {
            AlertToast(displayMode: .hud, type: .regular, title: dataManager.removedPostMessage)
        }
        .toast(isPresenting: $dataManager.removedComment) {
            AlertToast(displayMode: .hud, type: .regular, title: dataManager.removedCommentMessage)
        }
    }
    
    var karmaComponent : some View {
        HStack {
            HStack {
                Spacer()
                
                HStack(spacing: 15) {
                    Image(systemName: "star.bubble")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.screenWidth / 10)
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                    
                    VStack(alignment: .leading) {
                        Text("\(dataManager.postKarma)")
                            .font(.title.bold())
                            .foregroundColor(Color(UIColor.label))
                        
                        Text("Post Karma")
                            .font(.caption.bold())
                            .foregroundColor(Color.pongSecondaryText)
                    }
                }
                
                Spacer()
                Spacer()
                
                HStack(spacing: 15) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.screenWidth / 10)
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                    
                    VStack(alignment: .leading) {
                        Text("\(dataManager.commentKarma)")
                            .font(.title.bold())
                            .foregroundColor(Color(UIColor.label))
                        
                        Text("Comment Karma")
                            .font(.caption.bold())
                            .foregroundColor(Color.pongSecondaryText)
                    }
                }

                
                Spacer()
            }
            .padding()

        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .padding()
    }
    
    // component for toolbar picker
    var toolbarPickerComponent : some View {
        HStack(spacing: 30) {
            ForEach([ProfileFilter.posts, ProfileFilter.comments, ProfileFilter.about], id: \.self) { filter in
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    profileVM.selectedProfileFilter = filter
                } label: {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        Text(filter.title)
                            .font(.subheadline.bold())
                            .foregroundColor(profileVM.selectedProfileFilter == filter ? Color.pongAccent : Color.pongSecondaryText)
                        
                        Spacer()
                        
                        if profileVM.selectedProfileFilter == filter {
                            Color.pongAccent
                                .frame(height: 2)
                                .matchedGeometryEffect(id: "underline",
                                                       in: namespace,
                                                       properties: .frame)
                        } else {
                            Color.clear.frame(height: 2)
                        }
                    }
                    .animation(.spring(), value: profileVM.selectedProfileFilter)
                }
            }
        }
        .frame(maxHeight: 30)
    }
    
    // MARK: Custom Feed Stack
    @ViewBuilder
    func customProfileStack(filter: ProfileFilter, tab : ProfileFilter) -> some View {
        List {
            // MARK: Posts
            if tab == .posts {
                if dataManager.profilePosts != [] {
                    ForEach($dataManager.profilePosts, id: \.id) { $post in
                        PostBubble(post: $post, isLinkActive: .constant(false), conversation: .constant(defaultConversation))
                            .buttonStyle(PlainButtonStyle())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.pongSystemBackground)
                        
                        CustomListDivider()
                    }
                    .listRowInsets(EdgeInsets())
                } else {
                    VStack(alignment: .center, spacing: 15) {

                        HStack(alignment: .center) {
                            Spacer()

                            Image("VoidImage")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: UIScreen.screenWidth / 2)

                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            Text("you have no posts")
                                .font(.title.bold())
                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Go make a post!")
                                .font(.caption)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.pongSystemBackground)
                    .listRowSeparator(.hidden)
                    .frame(height: UIScreen.screenHeight / 2)
                }
            }
            // MARK: Comments
            else if tab == .comments {
                if dataManager.profileComments != [] {
                    ForEach($dataManager.profileComments, id: \.id) { $comment in

                        ProfileCommentBubble(comment: $comment)
                            .buttonStyle(PlainButtonStyle())
                            .environmentObject(dataManager)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.pongSystemBackground)
                        
                        CustomListDivider()
                        
                    }
                } else {
                    VStack(alignment: .center, spacing: 15) {

                        HStack(alignment: .center) {
                            Spacer()

                            Image("VoidImage")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: UIScreen.screenWidth / 2)

                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            Text("you have no comments")
                                .font(.title.bold())
                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Go make a comment!")
                                .font(.caption)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.pongSystemBackground)
                    .listRowSeparator(.hidden)
                    .frame(height: UIScreen.screenHeight / 2)
                }
            }
            // MARK: About
            else if tab == .about {
                // create a lazy v grid with two equally sized columns
                LazyVGrid(columns: [GridItem(.fixed((UIScreen.screenWidth - 20) / 2)), GridItem(.fixed((UIScreen.screenWidth - 20) / 2))], spacing: 15) {
                    aboutComponent(image: "bookmark", title: "POST KARMA", data: "\(dataManager.postKarma)")
                    aboutComponent(image: "bookmark", title: "COMMENT KARMA", data: "\(dataManager.commentKarma)")
                    aboutComponent(image: "bookmark", title: "DATE JOINED", data: "\(String(describing: DAKeychain.shared["dateJoined"]!))")
                    aboutComponent(image: "bookmark", title: "FRIENDS REFERRED", data: "100")
                }
                .listRowBackground(Color.pongSystemBackground)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
        }
        .scrollContentBackgroundCompat()
        .background(Color.pongSystemBackground)
        .environment(\.defaultMinListRowHeight, 0)
        .listStyle(PlainListStyle())
        .refreshable{
            profileVM.triggerRefresh(tab: tab, dataManager: dataManager)
        }
    }
    
    
    // MARK: About Component
    @ViewBuilder
    func aboutComponent(image : String, title : String, data : String) -> some View {
        HStack {
            Image(systemName: "\(image)")
            
            VStack(alignment: .leading) {
                HStack {
                    Text("\(title)")
                        .font(.caption.bold())
                        .foregroundColor(Color.pongLightGray)
                    
                    Spacer()
                }

                
                HStack {
                    Text("\(data)")
                        .font(.headline.bold())
                        .foregroundColor(Color.pongLabel)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.pongSecondarySystemBackground, lineWidth: 2)
        )
        .padding(3)
    }
}

