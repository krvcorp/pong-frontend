import SwiftUI
import PopupView

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataManager : DataManager
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
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                }
                .background(Color(UIColor.systemGroupedBackground))
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            }
            // Navigation bar
            .navigationTitle("Your Profile")
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
        .accentColor(Color(UIColor.label))
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var karmaComponent : some View {
        HStack {
            HStack {
                Spacer()
                
                VStack(alignment: .center) {
                    Text("Karma")
                        .font(.title.bold())
                    Text("\(dataManager.totalKarma)")
                        .font(.title.bold())
                        .foregroundColor(Color(UIColor(named: "PongPrimary")!))
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("Views")
                        .font(.title.bold())
                    Text("\(dataManager.postKarma)")
                        .font(.title.bold())
                        .foregroundColor(Color(UIColor(named: "PongPrimary")!))
                }
                
                Spacer()
//
//                Spacer()
//
//                VStack {
//                    Text("Comment")
//                        .font(.title3.bold())
//                    Text("\(dataManager.commentKarma)")
//                        .font(.title3.bold())
//                        .foregroundColor(Color(UIColor(named: "PongPrimary")!))
//                }
            }
            .padding()

        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .padding()
    }
    
    // component for toolbar picker
    var toolbarPickerComponent : some View {
        HStack {
            ForEach(ProfileFilter.allCases, id: \.self) { filter in
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    profileVM.selectedProfileFilter = filter
                } label: {
                    if profileVM.selectedProfileFilter == filter {
                        HStack {
                            Image(systemName: filter.filledImageName)
                            Text(filter.title)
                                .bold()
                        }
                        .shadow(color: Color(UIColor(named: "PongPrimarySelected")!), radius: 10, x: 0, y: 0)
                        .foregroundColor(Color(UIColor(named: "PongPrimarySelected")!))

                    } else {
                        HStack{
                            Image(systemName: filter.imageName)
                            Text(filter.title)
                        }
                        .foregroundColor(Color(UIColor(named: "PongPrimary")!))
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
                        CustomListDivider()
                        
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                            .listRowSeparator(.hidden)
                    }
                } else {
                    VStack(alignment: .center, spacing: 15) {
                        HStack(alignment: .center) {
                            Spacer()
                            
                            Image("pong_transparent_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: UIScreen.screenWidth / 3)
                            
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
                    .listRowBackground(Color(UIColor.secondarySystemBackground))
                    .listRowSeparator(.hidden)
                }
            }
            else if tab == .comments {
                if dataManager.profileComments != [] {
                    ForEach($dataManager.profileComments, id: \.id) { $comment in
                        CustomListDivider()
                        
                        ProfileCommentBubble(comment: $comment)
                            .buttonStyle(PlainButtonStyle())
                            .environmentObject(profileVM)
                            .listRowSeparator(.hidden)
                    }
                } else {
                    VStack(alignment: .center, spacing: 15) {
                        HStack(alignment: .center) {
                            Spacer()
                            
                            Image("pong_transparent_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: UIScreen.screenWidth / 3)
                            
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
                            Text("Go make a comment!")
                                .font(.caption)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color(UIColor.secondarySystemBackground))
                    .listRowSeparator(.hidden)
                }
            }
            else if tab == .awards {
                ForEach($dataManager.awards, id: \.self) { $award in
                    CustomListDivider()
                    
                }
            }
            else if tab == .saved {
                if dataManager.profileSavedPosts != [] {
                    ForEach($dataManager.profileSavedPosts, id: \.id) { $post in
                        Section {
                            CustomListDivider()
                            
                            PostBubble(post: $post)
                                .buttonStyle(PlainButtonStyle())
                                .listRowSeparator(.hidden)
                        }
                    }
                } else {
                    VStack(alignment: .center, spacing: 15) {
                        HStack(alignment: .center) {
                            Spacer()
                            
                            Image("pong_transparent_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: UIScreen.screenWidth / 3)
                            
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
                    .listRowBackground(Color(UIColor.secondarySystemBackground))
                    .listRowSeparator(.hidden)
                }
            }
        }
        .environment(\.defaultMinListRowHeight, 0)
        .listStyle(PlainListStyle())
        .refreshable{
            profileVM.triggerRefresh(tab: tab, dataManager: dataManager)
        }
    }
}

