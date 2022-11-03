//
//  NewPollViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/31/22.
//

import Foundation
import SwiftUI

class NewPollViewModel: ObservableObject {
    let characterLimit = 25
    @Published var allowSkipVoting : Bool = false
    @Published var pollOptions : [String] = []
    
    // MARK: Reset
    /// Resets poll to be default
    func reset() {
        self.allowSkipVoting = false
        self.pollOptions = []
    }
    
    // MARK: Instantiate
    /// Creates poll with two empty rows
    func instantiate() {
        self.pollOptions = ["", ""]
    }
    
    // MARK: Limit
    /// Character limit
    func limit(index : Int) {
        if pollOptions[index].count > characterLimit {
            pollOptions[index] = String(pollOptions[index].prefix(characterLimit))
        }
    }
    
    // MARK: Validate
    /// Ensure none of the entries are empty on post
    func validate() -> Bool {
        if pollOptions.contains(where: {$0 == ""}) {
            return false
        } else {
            return true
        }
    }
}
