import Foundation
import SwiftUI

extension View {
    // rounded corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    // some shit with the exyte popup
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
}

// roundedcorner
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// allows swipe back to go back
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

// screen width/height extension
extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

// remove duplicate function for posts
//extension Array where Element == Post {
//    func removingDuplicates() -> Array {
//        return reduce(into: []) { result, element in
//            if !result.contains(where: { $0.id == element.id }) {
//                result.append(element)
//            }
//        }
//    }
//}

//extension Array where Element == ProfileComment {
//    func removingDuplicates() -> Array {
//        return reduce(into: []) { result, element in
//            if !result.contains(where: { $0.id == element.id }) {
//                result.append(element)
//            }
//        }
//    }
//}

// hashable remove dupe
public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}
