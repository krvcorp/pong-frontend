//
//  StartNewChatView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/4/22.
//

import SwiftUI

struct NewChatView: View {
    @State private var text = ""
    var messageArray = ["Hello", "How are u", "Good"]
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    CustomInputField(imageName: "magnifyingglass",
                                     placeholderText: "To",
                                     isSecureField: false,
                                     text: $text)
                    .padding()
                }
                
                ScrollView {

                }
                .padding(.top, 10)
                .background(.white)
                .cornerRadius(30, corners: [.topLeft, .topRight])
                 
            }
            .background(.gray)
            
            MessageField()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("New Chat")
                    .font(.title.bold())
            }
            
        }
    }
}

struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        NewChatView()
    }
}
