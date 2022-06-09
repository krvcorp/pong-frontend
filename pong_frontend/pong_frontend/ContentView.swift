//
//  ContentView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/3/22.
//

import SwiftUI

struct ContentView: View {
        
    @State private var loggedIn = true

    var body: some View {
        if loggedIn {
            ZStack{
                FeedView()
                MainTabView()
            }
        } else {
            OnboardView(phoneNumber: .constant(""))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

