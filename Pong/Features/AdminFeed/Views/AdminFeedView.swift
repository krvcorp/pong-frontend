import SwiftUI

struct AdminFeedView: View {
    // MARK: ViewModels
    @StateObject var adminFeedVM = AdminFeedViewModel()
    
    var body: some View {
        VStack {
            toolbarPickerComponent
                .padding(.vertical)
                .background(Color.pongSystemBackground)
            
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
                .background(Color.pongSystemBackground)
            }
            .background(Color.pongSystemBackground)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
        }
        .background(Color.pongSystemBackground)
        .onAppear {
            adminFeedVM.getPosts()
            adminFeedVM.getComments()
        }
        .navigationBarTitle("Admin View")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: ToolbarPickerComponent
    var toolbarPickerComponent : some View {
        HStack(spacing: 30) {
            ForEach(AdminFilter.allCases, id: \.self) { filter in
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    adminFeedVM.selectedFilter = filter
                } label: {
                    if adminFeedVM.selectedFilter == filter {
                        HStack(spacing: 5) {
                            Text(filter.title)
                                .bold()
                        }
                        .foregroundColor(Color.pongAccent)

                    } else {
                        HStack(spacing: 5) {
                            Text(filter.title)
                        }
                        .foregroundColor(Color.pongSecondaryText)
                    }
                }
                .background(Color.pongSystemBackground)
            }
        }
        .background(Color.pongSystemBackground)
    }
}
