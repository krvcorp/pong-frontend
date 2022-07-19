//
//  Extensions.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/5/22.
//

import Foundation
import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

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

