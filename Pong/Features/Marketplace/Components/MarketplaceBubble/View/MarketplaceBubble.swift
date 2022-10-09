//
//  MarketplaceBubble.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/25/22.
//

import SwiftUI
import Kingfisher

struct MarketplaceBubble: View {
    @Binding var marketplaceItem : MarketplaceItem
    
    var body: some View {
        NavigationLink(destination: MarketplaceItemView(marketplaceItem: $marketplaceItem)) {
            ZStack {
                // MARK: Image
                if let index = self.marketplaceItem.images.firstIndex(where: {$0.featured}) {
                    KFImage(URL(string: "\(marketplaceItem.images[index].image)")!)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fill)
                        .layoutPriority(-1)
                        .cornerRadius(10)
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Spacer()
                        
                        VStack {
                            HStack {
                                Text("\(marketplaceItem.name)")
                                Spacer()
                            }
                            
                            HStack {
                                Text("\(marketplaceItem.price)")
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
