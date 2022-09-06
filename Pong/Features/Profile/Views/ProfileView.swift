import SwiftUI
import AlertToast

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
                    Image(systemName: "sun.min")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.screenWidth / 10)
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                    
                    VStack(alignment: .leading) {
                        Text("\(dataManager.totalKarma)")
                            .font(.title.bold())
                            .foregroundColor(Color(UIColor.label))
                        
                        Text("Karma")
                            .font(.headline.bold())
                            .foregroundColor(Color(UIColor.systemGray))
                    }
                }
                
                Spacer()
                Spacer()
                
                HStack(spacing: 15) {
                    Image(systemName: "chart.bar")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.screenWidth / 10)
                        .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                    
                    VStack(alignment: .leading) {
                        Text("\(dataManager.postKarma)")
                            .font(.title.bold())
                            .foregroundColor(Color(UIColor.label))
                        
                        Text("Views")
                            .font(.headline.bold())
                            .foregroundColor(Color(UIColor.systemGray))
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
                        .shadow(color: SchoolManager.shared.schoolPrimaryColor(), radius: 10, x: 0, y: 0)
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
                        
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(UIColor.systemBackground))
                        
                        CustomListDivider()
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

                        ProfileCommentBubble(comment: $comment)
                            .buttonStyle(PlainButtonStyle())
                            .environmentObject(dataManager)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(UIColor.systemBackground))
                        
                        CustomListDivider()
                        
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
            else if tab == .saved {
                if dataManager.profileSavedPosts != [] {
                    ForEach($dataManager.profileSavedPosts, id: \.id) { $post in
                        Section {
                            PostBubble(post: $post)
                                .buttonStyle(PlainButtonStyle())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color(UIColor.systemBackground))
                            CustomListDivider()
                            
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

