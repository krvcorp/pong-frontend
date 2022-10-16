//
//  ShareSheet.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import SwiftUI

struct ShareSheet : UIViewControllerRepresentable {
    var items : [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
    
    func getText(post_id: String) -> String{
        return("https://www.pong.college/post/\(post_id)/")
    }
}
