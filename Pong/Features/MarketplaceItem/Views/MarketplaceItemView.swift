//
//  MarketplaceItemView.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/25/22.
//

import SwiftUI
import Kingfisher

struct MarketplaceItemView: View {
    @Binding var marketplaceItem: MarketplaceItem
    
    var body: some View {
        ScrollView {
            VStack{
                // MARK: Image
//                if let imageUrl = marketplaceItem.image {
//                    KFImage(URL(string: "\(imageUrl)")!)
//                        .resizable()
//                        .scaledToFit()
//                        .aspectRatio(contentMode: .fill)
//                        .layoutPriority(-1)
//                        .cornerRadius(10)
//                }
                
                VStack {
                    HStack {
                        Text("\(marketplaceItem.name)")
                            .font(.title2.bold())
                        
                        Spacer()
                    }
                    HStack {
                        Text("\(marketplaceItem.price)")
                            .font(.title.bold())
                            .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Posted on \(marketplaceItem.date)")
                            .font(.subheadline)
                        Spacer()
                    }
                }
                
                Button {
                    print("DEBUG: reserve")
                } label: {
                    HStack {
                        Image(systemName: "cart")
                        
                        Text("Reserve")
                            .font(.title.bold())
                    }
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(SchoolManager.shared.schoolPrimaryColor())
                    .cornerRadius(10)

                }

                Button {
                    print("DEBUG: message")
                } label: {
                    HStack {
                        Image(systemName: "bubble.left")
                        
                        Text("Message")
                            .font(.title.bold())
                    }
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .foregroundColor(Color(UIColor.label))
                    .cornerRadius(10)

                }
                
                Button {
                    print("DEBUG: report")
                } label: {
                    HStack {
                        Text("Report")
                            .font(.title2)
                    }
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .foregroundColor(Color.pongSecondaryText)
                    .cornerRadius(10)

                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("\(marketplaceItem.name)")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "share")
                }
            }
        }
    }
}
