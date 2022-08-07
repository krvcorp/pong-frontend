//
//  Extensions.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/5/22.
//

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

// upload image
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

/// A custom scroll view that supports pull to refresh using the `refreshable()` modifier.
public struct RefreshableScrollView<Content: View>: View {
    let refreshControl: () -> UIRefreshControl
    @ViewBuilder let content: () -> Content

    public init(
        refreshControl: @autoclosure @escaping () -> UIRefreshControl = .init(),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.refreshControl = refreshControl
        self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollViewControllerRepresentable(refreshControl: refreshControl()) {
                content()
                    .frame(width: proxy.size.width)
            }
        }
    }
}

struct ScrollViewControllerRepresentable<Content: View>: UIViewControllerRepresentable {
    let refreshControl: UIRefreshControl
    @ViewBuilder let content: () -> Content
    @Environment(\.refresh) private var action
    @State var isRefreshing: Bool = false

    init(refreshControl: UIRefreshControl, @ViewBuilder content: @escaping () -> Content) {
        self.refreshControl = refreshControl
        self.content = content
    }

    func makeUIViewController(context: Context) -> ScrollViewController<Content> {
        let viewController = ScrollViewController(
            refreshControl: refreshControl,
            view: content()
        )
        viewController.onRefresh = {
            refresh()
        }
        return viewController
    }

    func updateUIViewController(_ viewController: ScrollViewController<Content>, context: Context) {
        viewController.hostingController.rootView = content()
        viewController.hostingController.view.setNeedsUpdateConstraints()

        if isRefreshing {
            viewController.refreshControl.beginRefreshing()
        } else {
            viewController.refreshControl.endRefreshing()
        }
    }

    func refresh() {
        Task {
            isRefreshing = true
            await action?()
            isRefreshing = false
        }
    }
}

class ScrollViewController<Content: View>: UIViewController, UIScrollViewDelegate {
    let scrollView = UIScrollView()
    let refreshControl: UIRefreshControl
    let hostingController: UIHostingController<Content>

    var onRefresh: (() -> Void)?

    init(refreshControl: UIRefreshControl, view: Content) {
        self.refreshControl = refreshControl
        hostingController = .init(rootView: view)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = scrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        scrollView.refreshControl = refreshControl
        scrollView.delegate = self

        hostingController.willMove(toParent: self)

        scrollView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])

        // `addChild` must be called *after* the layout constraints have been set, or a layout bug will occur
        addChild(hostingController)
        hostingController.didMove(toParent: self)
        hostingController.view.backgroundColor = .clear
    }

    @objc func didPullToRefresh(_ sender: UIRefreshControl) {
        onRefresh?()
    }
}

// screen width/height extension
extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}


// MARK: Custom View Extensions
// Offset Extensions
extension View{
    @ViewBuilder
    func offsetX(completion: @escaping (CGFloat)->())->some View{
        self
            .overlay {
                GeometryReader{proxy in
                    let minX = proxy.frame(in: .global).minX
                    Color.clear
                        .preference(key: OffsetKey.self, value: minX)
                        .onPreferenceChange(OffsetKey.self) { value in
                            completion(value)
                        }
                }
            }
    }

    // MARK: Previou,Current Offset To Find the Direction Of Swipe
    @ViewBuilder
    func offsetY(completion: @escaping (CGFloat,CGFloat)->())->some View{
        self
            .modifier(OffsetHelper(onChange: completion))
    }
    
    // MARK: Safe Area
    func safeArea()->UIEdgeInsets{
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return .zero}
        guard let safeArea = scene.windows.first?.safeAreaInsets else{return .zero}
        return safeArea
    }
}

// MARK: Offset Helper
struct OffsetHelper: ViewModifier{
    var onChange: (CGFloat,CGFloat)->()
    @State var currentOffset: CGFloat = 0
    @State var previousOffset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader{proxy in
                    let minY = proxy.frame(in: .named("SCROLL")).minY
                    Color.clear
                        .preference(key: OffsetKey.self, value: minY)
                        .onPreferenceChange(OffsetKey.self) { value in
                            previousOffset = currentOffset
                            currentOffset = value
                            onChange(previousOffset,currentOffset)
                        }
                }
            }
    }
}

// MARK: Offset Key
struct OffsetKey: PreferenceKey{
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: Bounds Preference Key For Identiying Height of The Header View
struct HeaderBoundsKey: PreferenceKey{
    static var defaultValue: Anchor<CGRect>?
    
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue()
    }
}

// MARK: Universal Interaction Manager
class InteractionManager: NSObject,ObservableObject,UIGestureRecognizerDelegate{
    @Published var isInteracting: Bool = false
    @Published var isGestureAdded: Bool = false
    
    func addGesture(){
        if !isGestureAdded{
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(onChange(gesture: )))
            gesture.name = "UNIVERSAL"
            gesture.delegate = self
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return}
            guard let window = windowScene.windows.last?.rootViewController else{return}
            window.view.addGestureRecognizer(gesture)
            isGestureAdded = true
        }
    }
    
    // MARK: Removing Gesture
    func removeGesture(){
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return}
        guard let window = windowScene.windows.last?.rootViewController else{return}
        
        window.view.gestureRecognizers?.removeAll(where: { gesture in
            return gesture.name == "UNIVERSAL"
        })
        isGestureAdded = false
    }
    
    @objc
    func onChange(gesture: UIPanGestureRecognizer){
        isInteracting = (gesture.state == .changed)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// scrollrefreshable
struct PullToRefresh: View {
    
    var coordinateSpaceName: String
    var onRefresh: ()->Void
    
    @State var needRefresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).midY > 50) {
                Spacer()
                    .onAppear {
                        needRefresh = true
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 10) {
                Spacer()
                    .onAppear {
                        if needRefresh {
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                } else {
                    Text("⬇️")
                }
                Spacer()
            }
        }.padding(.top, -50)
    }
}
