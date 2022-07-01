//
//  MessageField.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/5/22.
//

import SwiftUI

struct MessageField: View {
    @State private var message = ""
        
    var body: some View {
        HStack {
            CustomTextField(placeholder: Text("Enter your message here"), text: $message)
            
            Button {
                print("DEBUG: Message sent")
                message = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(Color(UIColor.systemBackground))
                    .padding(10)
                    .background(.indigo)
                    .cornerRadius(50)
            }

        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemFill))
        .cornerRadius(50)
        .padding()
    }
}

struct MessageField_Previews: PreviewProvider {
    static var previews: some View {
        MessageField()
    }
}

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool) -> () = { _ in}
    var commit: () -> () = {}
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                placeholder
                    .opacity(0.5)
                
            }
            
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}
