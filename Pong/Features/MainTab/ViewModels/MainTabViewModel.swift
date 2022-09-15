//
//  MainTabViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/5/22.
//
import Foundation
import Combine

class MainTabViewModel: ObservableObject {
    /// This is true when the user has selected the Item with the custom action
    @Published var isCustomItemSelected: Bool = false
    
    @Published var newPostDetected: Bool = false
    @Published var openDMsDetected: Bool = false
    
    @Published var scrollToTop : Bool = false
    
    /// This is the index of the item that fires a custom action
    let customActiontemindex: Int


    var previousItem: Int

    var itemSelected: Int {
        didSet {
            if itemSelected == customActiontemindex {
                previousItem = oldValue
                itemSelected = oldValue
                isCustomItemSelected = true
            }
        }
    }

    func reset() {
        itemSelected = previousItem
    }

    init(initialIndex: Int = 1, customItemIndex: Int) {
        self.customActiontemindex = customItemIndex
        self.itemSelected = initialIndex
        self.previousItem = initialIndex
    }
    
    func newPost() {
        self.isCustomItemSelected = false
        self.itemSelected = 1
        self.newPostDetected.toggle()
    }
    
    func openDMs() {
        self.itemSelected = 1
        self.openDMsDetected.toggle()
    }
}
