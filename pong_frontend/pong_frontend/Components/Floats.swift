//
//  Floats.swift
//  Pong.app
//
//  Created by Khoi Nguyen
//

import SwiftUI
import ExytePopupView

struct FloatShowingCodeWrong: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Error")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                
                Text("Your code is wrong.")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .opacity(0.8)
            }
            
            Spacer()
            
            Image(systemName: "xmark.octagon.fill")
                .aspectRatio(1.0, contentMode: .fit)
                .foregroundColor(Color(UIColor.systemBackground))
        }
        .padding(16)
        .background(Color(UIColor.label).cornerRadius(12))
        .shadow(color: Color(UIColor.label).opacity(0.5), radius: 40, x: 0, y: 12)
        .padding(.horizontal, 16)
    }
}
