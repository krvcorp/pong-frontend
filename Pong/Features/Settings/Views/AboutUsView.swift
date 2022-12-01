//
//  AboutUsView.swift
//  Pong
//
//  Created by Khoi Nguyen on 10/31/22.
//

import SwiftUI

struct AboutUsView: View {
    var body: some View {
        // MARK: Information
        VStack(spacing: 15) {
            HStack {
                Text("What is Pong?")
                    .font(.title2)
                    .fontWeight(.heavy)
                Spacer()
            }
            
            HStack {
                Text("Pong is an anonymous community exclusively for your college.")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                Text("We're here to see what you really think, feel, and believe.")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                Text("We want you to express your true opinions.")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                Text("Most importantly, we will never reveal/store your personal data.")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                Text("So be yourself.")
                    .font(.headline.bold())
                Spacer()
            }
        
            Spacer()
            
            // MARK: KRV Corp.
//            VStack {
//                Text("© 2022 KRV Corp.")
//                    .font(.system(Font.TextStyle.caption2, design: .rounded))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
//                    .font(.system(Font.TextStyle.caption2, design: .rounded))
//                    .frame(maxWidth: .infinity, alignment: .center)
//            }
//            .foregroundColor(Color.pongSecondaryText)
//            .padding(.top, 10)
        }
        .padding()
        .background(Color.pongSystemBackground)
        .navigationBarTitle("About Us")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            hideKeyboard()
        }
    }
}

struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutUsView()
    }
}
