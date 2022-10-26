//
//  NewMarketplaceItemView.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/25/22.
//

import SwiftUI

struct NewMarketplaceItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var newMarketplaceItemVM = NewMarketplaceItemViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                // MARK: 'NavigationBar'
                HStack(alignment: .center) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(UIColor.label))
                    }
                    .padding()
                    
                    Text("New Item")
                        .font(.title.bold())
                    
                    Spacer()
                    
                    Button {
                        print("DEBUG: Create")
                    } label: {
                        Text("Create")
                            .frame(minWidth: 100, maxWidth: 150)
                            .font(.system(size: 18).bold())
                            .padding()
                            .foregroundColor(Color(UIColor.systemBackground))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(SchoolManager.shared.schoolPrimaryColor(), lineWidth: 2)
                        )
                    }
                    .background(SchoolManager.shared.schoolPrimaryColor()) // If you have this
                    .cornerRadius(10)         // You also need the cornerRadius here
                }
                
                // MARK: Add media
                HStack {
                    Text("Add photos")
                        .foregroundColor(Color.pongSecondaryText)
                    Spacer()
                }
                
                HStack {
                    Button {
                        print("DEBUG: Camera")
                    } label: {
                        HStack {
                            HStack(spacing: 5) {
                                Spacer()
                                Image(systemName: "camera")
                                    .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                                Text("Camera")
                                    .font(.headline.bold())
                                    .foregroundColor(Color(UIColor.label))
                                Spacer()
                            }
                            .padding()

                        }
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray), lineWidth: 2))
                        .padding(2)

                    }
                    
                    Button {
                        print("DEBUG: Gallery")
                    } label: {
                        HStack {
                            HStack(spacing: 5) {
                                Spacer()
                                Image(systemName: "photo")
                                    .foregroundColor(SchoolManager.shared.schoolPrimaryColor())
                                Text("Gallery")
                                    .font(.headline.bold())
                                    .foregroundColor(Color(UIColor.label))
                                Spacer()
                            }
                            .padding()
                        }
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray), lineWidth: 2))
                        .padding(2)
                    }
                }
                .padding(.bottom)
                
                // MARK: Add post information
                HStack {
                    Text("Fill in the details")
                        .foregroundColor(Color(UIColor.lightGray))
                    Spacer()
                }
                VStack {
                    TextArea("Title *", text: $newMarketplaceItemVM.name)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray), lineWidth: 2))
                        .padding(2)
                    
                    TextArea("Description", text: $newMarketplaceItemVM.description)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray), lineWidth: 2))
                        .padding(2)
                    
                    TextArea("Price *", text: $newMarketplaceItemVM.price)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray), lineWidth: 2))
                        .padding(2)
                    
                }
                
                Spacer()
                
            }
            .padding()
        }
    }
}
