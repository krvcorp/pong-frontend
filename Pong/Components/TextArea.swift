//
//  TextArea.swift
//  TwitterSwiftUIYoutube
//
//  Created by Khoi Nguyen on 6/7/22.
//

import SwiftUI

struct TextArea: View {
    @Binding var text: String
    
    let placeholder: String
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
        UITextView.appearance().backgroundColor = .clear
        
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(.placeholderText))
                    .padding(.horizontal)
                    .padding(.vertical, 12)
            }
            
            TextEditor(text: $text)
                .padding(4)
        }
        .font(.title)
    }
}

