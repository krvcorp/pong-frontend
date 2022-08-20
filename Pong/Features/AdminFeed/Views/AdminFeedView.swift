import SwiftUI
import ScalingHeaderScrollView

struct AdminFeedView: View {
    // MARK: ViewModels
    @StateObject var adminFeedVM = AdminFeedViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
               ForEach($adminFeedVM.flaggedPosts, id: \.id) { $post in
                    AdminPostBubble(post: $post)
                        .buttonStyle(PlainButtonStyle())
                        .environmentObject(adminFeedVM)
                }
            }
            .padding(.top)
        }
        
        // MARK: OnAppear fetch all posts
        .onAppear {
            adminFeedVM.getPosts()
        }
        .navigationBarTitle("Admin View")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
}

struct AdminFeedView_Previews: PreviewProvider {
    static var previews: some View {
        AdminFeedView()
    }
}
