//
//  MarketplaceBubble.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/25/22.
//

import SwiftUI

struct MarketplaceBubble: View {
    @Binding var name : String
    
    var body: some View {
        ZStack {
            Image(systemName: "doc.plaintext")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .layoutPriority(-1)
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    
                    Text("\(name)")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color(UIColor.systemBackground))
                    
                    Text("$10")
                        .font(.subheadline.bold())
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color(UIColor.systemBackground))
                }
                
                Spacer()
            }
        }
        .clipped()
        .aspectRatio(1, contentMode: .fit)
        .border(Color.red)
    }
}
