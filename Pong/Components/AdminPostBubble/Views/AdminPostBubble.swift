import SwiftUI

struct AdminPostBubble: View {
    @Binding var post : Post
    @EnvironmentObject var adminFeedVM: AdminFeedViewModel
    @StateObject var adminPostBubbleVM = AdminPostBubbleViewModel()
   
    struct AlertIdentifier: Identifiable {
        enum Choice {
            case timeoutDay, timeoutWeek, unflag
        }
        
        var id: Choice
    }
    
    @State private var alertIdentifier: AlertIdentifier?
    
    var body: some View {
        VStack {
            NavigationLink(destination: PostView(post: $post)) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("\(adminPostBubbleVM.post.timeSincePosted)")
                            .font(.caption)
                            .padding(.bottom, 4)
          
                        Text(adminPostBubbleVM.post.title)
                            .multilineTextAlignment(.leading)
                        
                        // MARK: Image
                        if let imageUrl = adminPostBubbleVM.post.image {
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                VStack {
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                            } placeholder: {
                                VStack {
                                    ProgressView()
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                    Spacer()
                    VStack {
                        Text("\(adminPostBubbleVM.post.score)")
                    }
                    .frame(width: 25, height: 50)
                }
                .background(Color(UIColor.tertiarySystemBackground))

            }

            Color.black.frame(height:CGFloat(1) / UIScreen.main.scale)

            HStack {
                // MARK: Delete or More Button
                Menu {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        DispatchQueue.main.async {
                            adminPostBubbleVM.post = adminPostBubbleVM.post
                            self.alertIdentifier = AlertIdentifier(id: .timeoutDay)
                        }
                    }
                    label: {
                        Label("Apply 1 Day Timeout", systemImage: "exclamationmark.square")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        DispatchQueue.main.async {
                            adminPostBubbleVM.post = adminPostBubbleVM.post
                            self.alertIdentifier = AlertIdentifier(id: .timeoutWeek)
                        }
                    } label: {
                        Label("Apply 1 Week Timeout", systemImage: "exclamationmark.square")
                    }
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        DispatchQueue.main.async {
                            adminPostBubbleVM.post = adminPostBubbleVM.post
                            self.alertIdentifier = AlertIdentifier(id: .unflag)
                        }
                    } label: {
                        Label("Unflag Post", systemImage: "flag.slash")
                    }
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 30, height: 30)
                }
                .frame(width: 25, height: 25)
            }
        }
        .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.size.width - 50)
        .font(.system(size: 18).bold())
        .padding()
        .foregroundColor(Color(UIColor.label))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.tertiarySystemBackground), lineWidth: 5))
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
        .onAppear {
            adminPostBubbleVM.post = self.post
        }
        .onChange(of: adminPostBubbleVM.post) {
            self.post = $0
        }
        // MARK: Timeout Confirmation
        .alert(item: $alertIdentifier) { alert in
            switch alert.id {
            case .timeoutDay:
                return Alert(
                    title: Text("Apply timeout"),
                    message: Text("Are you sure you want to apply a 1 day timeout to \(adminPostBubbleVM.post.title)"),
                    primaryButton: .default(
                        Text("Cancel")
                    ),
                    secondaryButton: .destructive(
                        Text("Apply"),
                        action: adminPostBubbleVM.applyTimeoutDay
                    )
                )
            case .timeoutWeek:
                return Alert(
                    title: Text("Apply timeout"),
                    message: Text("Are you sure you want to apply a 1 week timeout to \(adminPostBubbleVM.post.title)"),
                    primaryButton: .default(
                        Text("Cancel")
                    ),
                    secondaryButton: .destructive(
                        Text("Apply"),
                        action: adminPostBubbleVM.applyTimeoutWeek
                    )
                )
            case .unflag:
                return Alert(
                    title: Text("Unflag post"),
                    message: Text("Are you sure you want to unflag \(adminPostBubbleVM.post.title)"),
                    primaryButton: .default(
                        Text("Cancel")
                    ),
                    secondaryButton: .destructive(Text("Unflag")){
                        adminPostBubbleVM.unflagPost(adminFeedVM: adminFeedVM)
    
                    }
                )
            }
        }
    }
}


