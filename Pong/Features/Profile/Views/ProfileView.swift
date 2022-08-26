import SwiftUI
import PopupView

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
//    @State private var selectedFilter: ProfileFilter = .posts
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
            profileVM.getProfile()
        }
    }
    
    var karmaComponent : some View {
        HStack {
            VStack {
                Text("Total")
                Text("\(profileVM.totalKarma)")
                    .bold()
            }
            .padding()
            
            VStack {
                Text("Post")
                Text("\(profileVM.postKarma)")
                    .bold()
            }
            .padding()
            
            VStack {
                Text("Comment")
                Text("\(profileVM.commentKarma)")
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
                        .shadow(color: colorScheme == .dark ? Color.poshGold : Color.poshDarkPurple, radius: 10, x: 0, y: 0)
                        .foregroundColor(colorScheme == .dark ? Color.poshGold : Color.poshDarkPurple)

                    } else {
                        HStack{
                            Image(systemName: filter.imageName)
                            Text(filter.title)
                        }
                        .foregroundColor(colorScheme == .dark ? Color.poshGold : Color.poshBlue)
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
                ForEach($profileVM.posts, id: \.id) { $post in
                    Section {
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            else if tab == .comments {
                ForEach($profileVM.comments, id: \.id) { $comment in
                    
                }
            }
            else if tab == .awards {
                ForEach($profileVM.awards, id: \.id) { $award in
                    
                }
            }
            else if tab == .saved {
                ForEach($profileVM.saved, id: \.id) { $post in
                    Section {
                        PostBubble(post: $post)
                            .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .refreshable{
            print("DEBUG: Refresh")
        }
    }
}

