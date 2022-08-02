//
//  FloatWarning.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/2/22.
//

import SwiftUI

struct FloatWarning: View {
    var message : String
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Error")
                    .foregroundColor(.white)
                    .font(.headline.bold())
                
                Text("\(message)")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .opacity(1)
            }
            
            Spacer()
            
            Image(systemName: "xmark.octagon.fill")
                .aspectRatio(1.0, contentMode: .fit)
                .foregroundColor(.white)
        }
        .padding(16)
        .background(Color(.red).cornerRadius(12))
        .shadow(color: Color(UIColor.label).opacity(0.4), radius: 40, x: 0, y: 12)
        .padding(.horizontal, 16)
    }
}

struct FloatWarning_Previews: PreviewProvider {
    static var previews: some View {
        FloatWarning(message: "Warning")
    }
}
