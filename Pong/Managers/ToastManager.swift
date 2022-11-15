//
//  ToastManager.swift
//  Pong
//
//  Created by Khoi Nguyen on 11/15/22.
//

import Foundation

class ToastManager : ObservableObject {
    
    static let shared = ToastManager()
    
    @Published var toast = false
    @Published var toastMessage = "Updated!"
    
    @Published var errorToast = false
    @Published var errorPopup = false
    @Published var errorMessage = "Something went wrong!"
    @Published var errorSubMessage = "Unable to connect to network!"
    
    // MARK: Abstract Error Toast
    func errorToastDetected(message: String, subMessage: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.errorSubMessage = subMessage
            self.errorToast = true
        }
    }
    
    // MARK: Abstract Error Popup
    func errorPopupDetected(message : String) {
        DispatchQueue.main.async {
            self.errorPopup = true
            self.errorMessage = message
        }
    }
    
    // MARK: Abstract Normal Toast
    func toastDetected(message: String) {
        DispatchQueue.main.async {
            self.toastMessage = message
            self.toast = true
        }
    }
}
