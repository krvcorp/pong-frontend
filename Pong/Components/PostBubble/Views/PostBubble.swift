import Foundation
import SwiftUI

struct PostBubble: View {
    @Binding var post : Post
    
    var body: some View {
        if DAKeychain.shared["postBubble"] == "true" {
            PostBubbleA(post: $post)
        } else {
            PostBubbleB(post: $post)
        }
    }
}
