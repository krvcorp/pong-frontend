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
    
    func reset() {
        self.allowSkipVoting = false
        self.pollOptions = []
    }
    
    func instantiate() {
        self.pollOptions = ["", ""]
    }
    
    func limit(index : Int) {
        if pollOptions[index].count > characterLimit {
            pollOptions[index] = String(pollOptions[index].prefix(characterLimit))
        }
    }
    
    func validate() -> Bool {
        if pollOptions.contains(where: {$0 == ""}) {
            return false
        } else {
            return true
        }
    }
}
