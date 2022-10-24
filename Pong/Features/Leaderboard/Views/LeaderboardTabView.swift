import SwiftUI
import AlertToast
import Combine

// LeaderBoard but wrapped in a NavigationView
struct LeaderboardTabView: View {
    var body: some View {
        NavigationView {
            LeaderboardView()
        }
    }
}
