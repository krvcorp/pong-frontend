//
//  VerificationViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/21/22.
//

import Foundation

class VerificationViewModel: ObservableObject {
    @Published var showingCodeExpired : Bool = false
    @Published var showingCodeWrong : Bool = false
}
