import SwiftUI
import AlertToast

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var dataManager = DataManager.shared
    @StateObject private var profileVM = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                karmaComponent
                    .frame(maxWidth: .infinity)
                
                toolbarPickerComponent
                
                TabView(selection: $profileVM.selectedProfileFilter) {
                    ForEach(ProfileFilter.allCases, id: \.self) { tab in
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
            ForEach(ProfileFilter.allCases, id: \.self) { filter in
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    profileVM.selectedProfileFilter = filter
                } label: {
                    if profileVM.selectedProfileFilter == filter {
                        HStack(spacing: 5) {
                            Image(systemName: filter.filledImageName)
                            Text(filter.title)
                                .bold()
                        }
//                        .shadow(color: SchoolManager.shared.schoolPrimaryColor(), radius: 10, x: 0, y: 0)
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())

                    } else {
                        HStack(spacing: 5) {
                            Image(systemName: filter.imageName)
                            Text(filter.title)
                        }
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                    }
                }
            }
        }
    }
    
    // MARK: Custom Feed Stack
    @ViewBuilder
    func customProfileStack(filter: ProfileFilter, tab : ProfileFilter) -> some View {
        List {
            if tab == .posts {
                if dataManager.profilePosts != [] {
                    ForEach($dataManager.profilePosts, id: \.id) { $post in
                        PostBubble(post: $post, isLinkActive: .constant(false), conversation: .constant(defaultConversation))
                            .buttonStyle(PlainButtonStyle())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.pongSystemBackground)
                        
                        CustomListDivider()
                    }
                } else {
                    VStack(alignment: .center, spacing: 15) {
                        HStack(alignment: .center) {
                            Spacer()

                            Image("PongTransparentLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: UIScreen.screenWidth / 2)

                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            Text("No posts yet!")
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
                    .padding(.top, 20)
                    .listRowBackground(Color.pongSystemBackground)
                    .listRowSeparator(.hidden)
                }
            }
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

                            Image("PongTransparentLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: UIScreen.screenWidth / 2)

                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            Text("No comments yet!")
                                .font(.title.bold())
                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Share an opinion!")
                                .font(.caption)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.pongSystemBackground)
                    .listRowSeparator(.hidden)
                }
            }
            else if tab == .saved {
                if dataManager.profileSavedPosts != [] {
                    ForEach($dataManager.profileSavedPosts, id: \.id) { $post in
                        Section {
                            PostBubble(post: $post, isLinkActive: .constant(false), conversation: .constant(defaultConversation))
                                .buttonStyle(PlainButtonStyle())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.pongSystemBackground
                                )
                            CustomListDivider()
                            
                        }
                    }
                } else {
                    VStack(alignment: .center, spacing: 15) {
                        HStack(alignment: .center) {
                            Spacer()

                            Image("PongTransparentLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: UIScreen.screenWidth / 2)

                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            Text("No saved posts yet!")
                                .font(.title.bold())
                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Go bookmark something!")
                                .font(.caption)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.pongSystemBackground)
                    .listRowSeparator(.hidden)
                }
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
}

