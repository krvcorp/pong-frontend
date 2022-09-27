//
//  MarketplaceView.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/24/22.
//

import SwiftUI

struct MarketplaceView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var marketplaceItems = [MarketplaceItem(id: "1", title: "water bottle", price: "$5", image: "https://i.imgur.com/AR9cuIN.jpg", date: "09/25/22"),
                                   MarketplaceItem(id: "2", title: "colgate toothpaste", price: "$5", image: "https://i.imgur.com/HgK4fLM.jpg", date: "09/25/22"),
                                   MarketplaceItem(id: "3", title: "binance tshirt", price: "$10", image: "https://i.imgur.com/cJN4Irb.jpg", date: "09/26/22"),
                                   MarketplaceItem(id: "4", title: "harvard sweatshirt", price: "$25", image: "https://i.imgur.com/Yjp3WI5.jpg", date: "09/26/22"),
                                   MarketplaceItem(id: "5", title: "children's toy", price: "$5", image: "https://i.imgur.com/wpoFnGy.jpg", date: "09/25/22"),
                                   MarketplaceItem(id: "6", title: "adderall", price: "$10", image: "https://i.imgur.com/FeRnXx8.jpg", date: "09/26/22"),
                                   MarketplaceItem(id: "7", title: "mini fridge", price: "$50", image: "https://i.imgur.com/rqzhey2.png", date: "09/25/22"),
                                   MarketplaceItem(id: "8", title: "shirts", price: "$10", image: "https://img.wattpad.com/fb3f09503acdf850e047007e55c57ce950004c3b/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f776174747061642d6d656469612d736572766963652f53746f7279496d6167652f6947424b3166734c4e64377a45773d3d2d3637362e313631623837356335653731353161393735373931353633343639372e6a7067?s=fit&w=720&h=720", date: "09/25/22")]
    
    @State var showNewMarketplaceItem : Bool = false
    
    private let columns : [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach($marketplaceItems, id: \.self) { $marketplaceItem in
                        MarketplaceBubble(marketplaceItem: $marketplaceItem)
                            .buttonStyle(PlainButtonStyle())
                            .background(Color(UIColor.systemBackground))
                            .padding(2)
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .background(Color(UIColor.secondarySystemBackground))
            .navigationTitle("Marketplace")
            .toolbar {
                ToolbarItem {
                    HStack(spacing: 0) {
//                        NavigationLink(destination: NewMarketplaceItem()) {
//                            Image(systemName: "plus.app")
//                        }
                        Button {
                            showNewMarketplaceItem = true
                        } label: {
                            Image(systemName: "plus.app")
                        }

                        
                        NavigationLink(destination: MessageRosterView()) {
                            Image(systemName: "paperplane")
                        }
                    }
                }
            }
        }
        .accentColor(Color(UIColor.label))
        .sheet(isPresented: $showNewMarketplaceItem) {
            NewMarketplaceItem()
        }
    }
}

struct MarketplaceView_Previews: PreviewProvider {
    static var previews: some View {
        MarketplaceView()
    }
}
