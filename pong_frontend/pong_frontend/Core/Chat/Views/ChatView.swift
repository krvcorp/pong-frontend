//
//  ChatView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/4/22.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var text = ""
    @State private var showChatSideMenu = false
    var messageArray = ["Hello", "How are u", "Good"]
    
    var body: some View {
        VStack {
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
                        ForEach(messageArray, id: \.self) { text in
                            MessageBubble(message: Message(id: "12345", text: text, received: true, timestamp: Date()))
                        }
                    }
                }
                .padding(.top, 10)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(30, corners: [.topLeft, .topRight])
                 
            }
            .background(.secondary)
            
            MessageField()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Raunak Daga")
                    .font(.title.bold())
            }
            
            ToolbarItem(){
                Button {
                    print("DEBUG: Profile")
                    showChatSideMenu.toggle()
                } label: {
                    Image(systemName: "person.crop.circle")
                }
                .padding()
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
