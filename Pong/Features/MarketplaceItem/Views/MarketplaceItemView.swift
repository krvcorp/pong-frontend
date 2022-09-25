//
//  MarketplaceItemView.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/25/22.
//

import SwiftUI

struct MarketplaceItemView: View {
    var body: some View {
        ScrollView {
            VStack{
                Image(systemName: "doc.plaintext")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding()
                
                VStack {
                    HStack {
                        Text("Arjun")
                            .font(.title2.bold())
                        
                        Spacer()
                    }
                    HStack {
                        Text("$10.00")
                            .font(.title.bold())
                            .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Posted on September 30, 2022")
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
                    .foregroundColor(Color(UIColor.lightGray))
                    .cornerRadius(10)

                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "share")
                }
            }
        }
    }
}

struct MarketplaceItemView_Previews: PreviewProvider {
    static var previews: some View {
        MarketplaceItemView()
    }
}
