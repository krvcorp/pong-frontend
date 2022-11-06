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
    
    @Published var openConversationsDetected: Bool = false
    @Published var openConversationDetected: Bool = false
    @Published var openConversation: Conversation = defaultConversation
    
    @Published var scrollToTop : Bool = false
    
    init(initialIndex: Int = 1, customItemIndex: Int) {
        self.customActiontemindex = customItemIndex
        self.itemSelected = initialIndex
        self.previousItem = initialIndex
    }
    
    /// This is the index of the item that fires a custom action
    let customActiontemindex: Int

    var previousItem: Int

    @Published var itemSelected: Int {
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
    
    func newPost() {
        self.isCustomItemSelected = false
        self.itemSelected = 1
        self.newPostDetected.toggle()
    }
    
    func openDMs(conversation: Conversation) {
        self.openConversation = conversation
        self.itemSelected = 1
        self.openConversationsDetected.toggle()
    }
}
