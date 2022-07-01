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
            // searchbar
            HStack {
                CustomInputField(imageName: "magnifyingglass",
                                 placeholderText: "Search messages",
                                 isSecureField: false,
                                 text: $text)
                .padding()
            }
            
            // messages stack
            ScrollView {
                LazyVStack {
                    ForEach(0 ... 20, id: \.self) { _ in
                        MessageBlock()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Messages")
                    .font(.title.bold())
            }
            
            ToolbarItem(){
                NavigationLink {
                    NewChatView()
                } label: {
                    Image(systemName: "plus.message.fill")
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
