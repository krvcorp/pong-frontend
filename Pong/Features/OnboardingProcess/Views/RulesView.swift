//
//  RulesView.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/31/22.
//

import SwiftUI

struct RulesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Rules!")
                .font(.title.bold())
            
            Image("OnboardRulesImage")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.screenWidth / 1.1)
            
            Text("Obviously there are special execptions.")
                .font(.title3)
            
            Text("[Rules](https://www.pong.blog/) are common sense. Basic shit like no threats, doxxing, or harassment.")
                .font(.title3)
            
            Spacer()
        }
        .background(Color.pongSystemBackground)
        .padding()
    }
}

struct RulesView_Previews: PreviewProvider {
    static var previews: some View {
        RulesView()
    }
}
