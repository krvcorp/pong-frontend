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
        NavigationLink(destination: MarketplaceItemView()) {
            ZStack {
                Image(systemName: "doc.plaintext")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .layoutPriority(-1)
                    .cornerRadius(10)
                
                HStack {
                    VStack(alignment: .leading) {
                        Spacer()
                        
                        VStack {
                            HStack {
                                Text("\(name)")
                                Spacer()
                            }
                            
                            HStack {
                                Text("$10")
                                    .font(.subheadline.bold())
                                Spacer()
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                    }
                }
            }
            .clipped()
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
