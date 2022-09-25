//
//  MarketplaceView.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/24/22.
//

import SwiftUI

struct MarketplaceView: View {
    
    @State var items = (1...50).map {"Item \($0)"}
    
    private let columns : [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach($items, id: \.self) { $item in
                        MarketplaceBubble(name: $item)
                            .padding(1)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .navigationTitle("Marketplace")
            .toolbar {
                ToolbarItem {
                    HStack(spacing: 0) {
                        NavigationLink(destination: NotificationsView()) {
                            Image(systemName: "bell")
                        }
                        
                        NavigationLink(destination: MessageRosterView()) {
                            Image(systemName: "paperplane")
                        }
                    }
                }
            }
        }
        .accentColor(Color(UIColor.label))
    }
}

struct MarketplaceView_Previews: PreviewProvider {
    static var previews: some View {
        MarketplaceView()
    }
}
