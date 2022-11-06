//
//  InformationView.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/31/22.
//

import SwiftUI

struct InformationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Be yourself with just a few [rules](https://www.pong.blog/). Basically, don't be an asshole")
                .font(.title.bold())
                .padding(.horizontal)
            
            Image("OnboardInformationImage")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.screenWidth / 1.1)
            
            Spacer()
        }
        .background(Color.pongSystemBackground)
        .padding()
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView()
    }
}
