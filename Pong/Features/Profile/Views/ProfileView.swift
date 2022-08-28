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
        .onAppear() {
            profileVM.getProfile(dataManager: dataManager)
        }
    }
    
    var karmaComponent : some View {
        HStack {
            VStack {
                Text("Total")
                Text("\(dataManager.totalKarma)")
                    .bold()
            }
            .padding()
            
            VStack {
                Text("Post")
                Text("\(dataManager.postKarma)")
                    .bold()
            }
            .padding()
            
            VStack {
                Text("Comment")
                Text("\(dataManager.commentKarma)")
                    .bold()
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
                ForEach($dataManager.profilePosts, id: \.id) { $post in
                    CustomListDivider()
                    
                    PostBubble(post: $post)
                        .buttonStyle(PlainButtonStyle())
                        .listRowSeparator(.hidden)
                }
            }
            else if tab == .comments {
                ForEach($dataManager.profileComments, id: \.id) { $comment in
                    CustomListDivider()
                    
                    ProfileCommentBubble(comment: $comment)
                        .buttonStyle(PlainButtonStyle())
                        .environmentObject(profileVM)
                        .listRowSeparator(.hidden)
                }
            }
            else if tab == .awards {
                ForEach($dataManager.awards, id: \.self) { $award in
                    CustomListDivider()
                    
                }
            }
            else if tab == .saved {
                ForEach($dataManager.profileSavedPosts, id: \.id) { $post in
                    Section {
                        CustomListDivider()
                        
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                            .listRowSeparator(.hidden)
                    }
                }
            }
        }
        .environment(\.defaultMinListRowHeight, 0)
        .listStyle(PlainListStyle())
        .refreshable{
            print("DEBUG: Refresh")
            profileVM.triggerRefresh(tab: tab, dataManager: dataManager)
        }
    }
}

