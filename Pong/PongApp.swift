//
//  PongMockupApp.swift
//  PongMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

@main
struct Pong: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
