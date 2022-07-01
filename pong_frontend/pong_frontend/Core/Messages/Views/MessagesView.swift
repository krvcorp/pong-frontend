//
//  MessagesView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/4/22.
//

import SwiftUI

struct MessagesView: View {
    @State private var text = ""
    
    var body: some View {
        VStack {
                        
            HStack {
                CustomInputField(imageName: "magnifyingglass",
                                 placeholderText: "Search messages",
                                 isSecureField: false,
                                 text: $text)
                .padding()
            }
            
            ScrollView {
                LazyVStack {
                    ForEach(0 ... 20, id: \.self) { _ in
                        MessageBlock()
                    }
                }
            }
            
        }

    }
       
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
