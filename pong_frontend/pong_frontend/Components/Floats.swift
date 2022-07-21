//
//  Floats.swift
//  Pong.app
//
//  Created by Khoi Nguyen
//

import SwiftUI
import PopupView

struct FloatShowingCodeWrong: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Error")
                    .foregroundColor(.white)
                    .font(.headline.bold())
                
                Text("Your code is wrong.")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .opacity(0.8)
            }
            
            Spacer()
            
            Image(systemName: "xmark.octagon.fill")
                .aspectRatio(1.0, contentMode: .fit)
                .foregroundColor(Color(UIColor.systemBackground))
        }
        .padding(16)
        .background(Color(.red).cornerRadius(12))
        .shadow(color: Color(UIColor.label).opacity(0.4), radius: 40, x: 0, y: 12)
        .padding(.horizontal, 16)
    }
}

struct FloatShowingCodeExpired: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Error")
                    .foregroundColor(.white)
                    .font(.headline.bold())
                
                Text("Your code has expired.")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .opacity(0.8)
            }
            
            Spacer()
            
            Image(systemName: "xmark.octagon.fill")
                .aspectRatio(1.0, contentMode: .fit)
                .foregroundColor(Color(UIColor.systemBackground))
        }
        .padding(16)
        .background(Color(.red).cornerRadius(12))
        .shadow(color: Color(UIColor.label).opacity(0.4), radius: 40, x: 0, y: 12)
        .padding(.horizontal, 16)
    }
}
