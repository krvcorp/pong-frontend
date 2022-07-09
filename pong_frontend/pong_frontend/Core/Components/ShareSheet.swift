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
