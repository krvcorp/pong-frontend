import SwiftUI
import AlertToast

struct ProfileView: View {
    @Namespace var namespace
    @Environment(\.colorScheme) var colorScheme
    
    @State var profilePosts = DataManager.shared.profilePosts
    @State var profileComments = DataManager.shared.profileComments
    @State var postKarma = DataManager.shared.postKarma
    @State var commentKarma = DataManager.shared.commentKarma
    @State var numberReferred = DataManager.shared.numberReferred
    
    @StateObject private var profileVM = ProfileViewModel()
    
    @State var selectedProfileFilter : ProfileFilter = .posts
    
    var body: some View {
        VStack {
            toolbarPickerComponent

            TabView(selection: $selectedProfileFilter) {
                ForEach([ProfileFilter.posts, ProfileFilter.comments, ProfileFilter.about], id: \.self) { tab in
                    customProfileStack(filter: selectedProfileFilter, tab: tab)
                        .tag(tab)
                        .background(Color.pongSystemBackground)
                }
            }
            .background(Color.pongSystemBackground)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .onChange(of: DataManager.shared.profilePosts, perform: { newValue in
            DispatchQueue.main.async {
                profilePosts = DataManager.shared.profilePosts
            }
        })
        .onChange(of: DataManager.shared.profileComments, perform: { newValue in
            DispatchQueue.main.async {
                profileComments = DataManager.shared.profileComments
            }
        })
        .onChange(of: DataManager.shared.postKarma, perform: { newValue in
            DispatchQueue.main.async {
                postKarma = DataManager.shared.postKarma
            }
        })
        .onChange(of: DataManager.shared.commentKarma, perform: { newValue in
            DispatchQueue.main.async {
                commentKarma = DataManager.shared.commentKarma
            }
        })
        .onChange(of: DataManager.shared.numberReferred, perform: { newValue in
            DispatchQueue.main.async {
                numberReferred = DataManager.shared.numberReferred
            }
        })
        .onAppear {
            self.profilePosts = DataManager.shared.profilePosts
            self.profileComments = DataManager.shared.profileComments
            self.postKarma = DataManager.shared.postKarma
            self.commentKarma = DataManager.shared.commentKarma
            self.numberReferred = DataManager.shared.numberReferred
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
                    Image("gear")
                        .font(Font.callout.weight(.thin))
                }
                .isDetailLink(false)
            }
        }
        .background(Color.pongSystemBackground)
        .accentColor(Color(UIColor.label))
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: KarmaComponent
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
                        Text("\(postKarma)")
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
                        Text("\(commentKarma)")
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
    
    // MARK: ToolbarPickerComponent
    var toolbarPickerComponent : some View {
        HStack(spacing: 30) {
            ForEach([ProfileFilter.posts, ProfileFilter.comments, ProfileFilter.about], id: \.self) { filter in
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    selectedProfileFilter = filter
                } label: {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        Text(filter.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(selectedProfileFilter == filter ? Color.pongAccent : Color.pongLabel)
                        
                        Spacer()
                        
                        if selectedProfileFilter == filter {
                            Color.pongAccent
                                .frame(height: 2)
                                .matchedGeometryEffect(id: "underline",
                                                       in: namespace,
                                                       properties: .frame)
                        } else {
                            Color.clear.frame(height: 2)
                        }
                    }
                    .animation(.spring(), value: selectedProfileFilter)
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
                if profilePosts != [] {
                    ForEach($profilePosts, id: \.id) { $post in
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.pongSystemBackground)
                        
                        CustomListDivider()
                    }
                    .listRowInsets(EdgeInsets())
                } else {
                    VStack(alignment: .center, spacing: 15) {

//                        HStack(alignment: .center) {
//                            Spacer()
//
//                            Image("VoidImage")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(maxWidth: UIScreen.screenWidth / 2)
//
//                            Spacer()
//                        }
                        
                        Spacer()
                        
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Your posts will show up here.")
                                .font(.title3.bold())
                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Go make one!")
                                .font(.caption)
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .listRowBackground(Color.pongSystemBackground)
                    .listRowSeparator(.hidden)
                    .frame(height: UIScreen.screenHeight / 2)
                }
            }
            // MARK: Comments
            else if tab == .comments {
                if profileComments != [] {
                    ForEach($profileComments, id: \.id) { $comment in

                        ProfileCommentBubble(comment: $comment)
                            .buttonStyle(PlainButtonStyle())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.pongSystemBackground)
                        
                        CustomListDivider()
                        
                    }
                } else {
                    VStack(alignment: .center, spacing: 15) {

//                        HStack(alignment: .center) {
//                            Spacer()
//
//                            Image("VoidImage")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(maxWidth: UIScreen.screenWidth / 2)
//
//                            Spacer()
//                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Your comments will show up here.")
                                .font(.title3.bold())
                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Let the world know what you think.")
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
                LazyVGrid(columns: [GridItem(.fixed((UIScreen.screenWidth - 20) / 2)), GridItem(.fixed((UIScreen.screenWidth - 20) / 2))], spacing: 15) {
                    aboutComponent(system: false, image: "bar.chart", title: "POST KARMA", data: "\(postKarma)")
                    aboutComponent(system: true, image: "star", title: "COMMENT KARMA", data: "\(commentKarma)")
                    aboutComponent(system: false, image: "calendar", title: "DATE JOINED", data: "\(String(describing: DAKeychain.shared["dateJoined"]!))")
                    aboutComponent(system: false, image: "friends", title: "FRIENDS REFERRED", data: "\(numberReferred)")
                }
                .listRowBackground(Color.pongSystemBackground)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            
            Rectangle()
                .fill(Color.pongSystemBackground)
                .listRowBackground(Color.pongSystemBackground)
                .frame(minHeight: 150)
                .listRowSeparator(.hidden)
        }
        .scrollContentBackgroundCompat()
        .background(Color.pongSystemBackground)
        .environment(\.defaultMinListRowHeight, 0)
        .listStyle(PlainListStyle())
        .refreshable{
            profileVM.triggerRefresh(tab: tab)
            await Task.sleep(500_000_000)
        }
    }
    
    // MARK: About Component
    @ViewBuilder
    func aboutComponent(system: Bool, image : String, title : String, data : String) -> some View {
        HStack {
            if system {
                Image(systemName: "\(image)")
                    .imageScale(.large)
            } else {
                Image("\(image)")
                    .imageScale(.large)
            }
            
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
        .padding(.vertical)
        .padding(.horizontal, 5)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.pongSecondarySystemBackground, lineWidth: 2)
        )
        .padding(1)
    }
}

