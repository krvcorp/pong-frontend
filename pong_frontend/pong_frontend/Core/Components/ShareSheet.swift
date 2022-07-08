//
//  ShareSheet.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import SwiftUI

// SHARE SHEET
struct ShareSheet : UIViewControllerRepresentable {
    // the data you need to share...
    var items : [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
}

// SOMETHING ABOUT MAKING IMAGE
extension UIView {
    func asImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

// LOGIC BEHIND CONVERTING A VIEW INTO A SHAREABLE IMAGE
//struct ShareView: View {
//    @State private var rect1: CGRect = .zero
//    @State private var uiimage: UIImage? = nil
//    @State var sheet = false
//    var body: some View {
//        VStack {
//            HStack {
//                PostBubble(post: default_post,
//                           expanded: false)
//                .background(RectGetter(rect: $rect1))
//                .onTapGesture {
//                    self.uiimage = UIApplication.shared.windows[0].rootViewController?.view.asImage(rect: self.rect1)
//                    sheet.toggle()
//                }
//                .sheet(isPresented: $sheet) {
//                    ShareSheet(items: [uiimage])
//                }
//            }
//
//            if uiimage != nil {
//                VStack {
//                    Text("Captured Image")
//                    Image(uiImage: self.uiimage!).padding(20).border(Color.secondary)
//                }.padding(20)
//            }
//        }
//    }
//}


// BAD BOY GETS A RECTANGLE
//struct RectGetter: View {
//    @Binding var rect: CGRect
//
//    var body: some View {
//        GeometryReader { proxy in
//            self.createView(proxy: proxy)
//        }
//    }
//
//    func createView(proxy: GeometryProxy) -> some View {
//        DispatchQueue.main.async {
//            self.rect = proxy.frame(in: .global)
//        }
//
//        return Rectangle().fill(Color.clear)
//    }
//}
