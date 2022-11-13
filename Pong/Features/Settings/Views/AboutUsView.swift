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
                Text("Who are we?")
                    .font(.title2)
                    .fontWeight(.heavy)
                Spacer()
            }
            
            HStack {
                Text("Two students who think connecting at college has room for improvement")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                Text("We are not affiliated with any institution, so please be yourself. We are not 🐀")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                Text("If you think you're like us and looking to do some fun stuff, reach out to us. We'd love to hear from you!")
                    .font(.headline)
                Spacer()
            }
        
            Spacer()
            
            // MARK: KRV Corp.
            VStack {
                Text("© 2022 KRV Corp.")
                    .font(.system(Font.TextStyle.caption2, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                    .font(.system(Font.TextStyle.caption2, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .foregroundColor(Color.pongSecondaryText)
            .padding(.top, 10)
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
