//
//  NewPollViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/31/22.
//

import Foundation

class NewPollViewModel: ObservableObject {
    @Published var allowSkipVoting : Bool = false
    @Published var pollOptions : [String] = [""]
    
    func reset() {
        self.allowSkipVoting = false
        self.pollOptions = ["", ""]
    }
}
