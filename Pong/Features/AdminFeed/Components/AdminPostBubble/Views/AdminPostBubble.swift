import SwiftUI
import Kingfisher

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
        ZStack {
            NavigationLink(destination: PostView(post: $post)) {
                EmptyView()
            }
            .opacity(0.0)
            .buttonStyle(PlainButtonStyle())
            
            // MARK: Main
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("\(adminPostBubbleVM.post.timeSincePosted)")
                            .font(.caption)
                            .padding(.bottom, 4)
          
                        Text(adminPostBubbleVM.post.title)
                            .multilineTextAlignment(.leading)
                        
                        // MARK: Image
                        if let imageUrl = post.image {
                            KFImage(URL(string: "\(imageUrl)")!)
                                .resizable()
                                .scaledToFit()
                                .frame(idealWidth: abs(UIScreen.screenWidth / 1.1), idealHeight: abs(CGFloat(post.imageHeight!) * (UIScreen.screenWidth / 1.1) / CGFloat(post.imageWidth!)), maxHeight: abs(CGFloat(150)))
                                .cornerRadius(15)
                        }
                        
                        // MARK: Poll
                        if post.poll != nil && post.image == nil {
                            PollView(post: $post)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    VStack {
                        Text("\(adminPostBubbleVM.post.score)")
                    }
                    .frame(width: 25, height: 50)
                }
                .background(Color(UIColor.tertiarySystemBackground))

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
        }
        .font(.system(size: 18).bold())
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
                return customAlert (
                    title: "Apply timeout",
                    message: "Are you sure you want to apply a 1 day timeout to \(adminPostBubbleVM.post.title)",
                    secondaryButtonText: "Apply",
                    secondaryButtonAction: {
                        adminPostBubbleVM.applyTimeout(adminFeedVM: adminFeedVM, time: 60 * 24)
                    }
                )
            case .timeoutWeek:
                return customAlert (
                    title: "Apply timeout",
                    message: "Are you sure you want to apply a 1 week timeout to \(adminPostBubbleVM.post.title)",
                    secondaryButtonText: "Apply",
                    secondaryButtonAction: {
                        adminPostBubbleVM.applyTimeout(adminFeedVM: adminFeedVM, time: 60 * 24 * 7)
                    }
                )
            case .unflag:
                return customAlert (
                    title: "Unflag post",
                    message: "Are you sure you want to unflag \(adminPostBubbleVM.post.title)",
                    secondaryButtonText: "Unflag",
                    secondaryButtonAction: {
                        adminPostBubbleVM.unflagPost(adminFeedVM: adminFeedVM)
                    }
                )
            }
        }
    }
    
    // MARK: CustomAlert
    func customAlert(title: String, message: String, secondaryButtonText: String, secondaryButtonAction: @escaping () -> Void) -> Alert {
        return Alert(
            title: Text(title),
            message: Text(message),
            primaryButton: .default(
                Text("Cancel")
            ),
            secondaryButton: .destructive(Text(secondaryButtonText)) {
                secondaryButtonAction()
            }
        )
    }
}


