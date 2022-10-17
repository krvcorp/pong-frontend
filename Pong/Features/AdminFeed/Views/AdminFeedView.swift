import SwiftUI

struct AdminFeedView: View {
    // MARK: ViewModels
    @StateObject var adminFeedVM = AdminFeedViewModel()
    
    var body: some View {
        VStack {
            toolbarPickerComponent
                .padding(.vertical)
            
            TabView(selection: $adminFeedVM.selectedFilter) {
                ForEach(AdminFilter.allCases, id: \.self) { tab in
                    List {
                        if tab == .posts {
                            ForEach($adminFeedVM.flaggedPosts, id: \.id) { $post in
                                AdminPostBubble(post: $post)
                                    .buttonStyle(PlainButtonStyle())
                                    .environmentObject(adminFeedVM)
                            }
                        } else if tab == .comments {
                            ForEach($adminFeedVM.flaggedComments, id: \.id) { $comment in
                                AdminCommentBubble(comment: $comment)
                                    .buttonStyle(PlainButtonStyle())
                                    .environmentObject(adminFeedVM)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        if adminFeedVM.selectedFilter == .posts {
                            adminFeedVM.getPosts()
                        } else if adminFeedVM.selectedFilter == .comments {
                            adminFeedVM.getComments()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
            }
            .background(Color(UIColor.systemGroupedBackground))
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
        }
        .onAppear {
            adminFeedVM.getPosts()
            adminFeedVM.getComments()
        }
        .navigationBarTitle("Admin View")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var toolbarPickerComponent : some View {
        HStack(spacing: 30) {
            ForEach(AdminFilter.allCases, id: \.self) { filter in
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    adminFeedVM.selectedFilter = filter
                } label: {
                    if adminFeedVM.selectedFilter == filter {
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
}

struct AdminFeedView_Previews: PreviewProvider {
    static var previews: some View {
        AdminFeedView()
    }
}
