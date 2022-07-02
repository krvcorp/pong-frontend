//
//  ChooseLocationView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/1/22.
//

import SwiftUI

struct ChooseLocationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedFilter: ChooseLocationFilterViewModel = .all
    @Namespace var animation
    @State private var text = ""
    
    
    var body: some View {
        
        
        VStack {
            // searchbar
            HStack {
                CustomInputField(imageName: "magnifyingglass",
                                 placeholderText: "Search communities",
                                 isSecureField: false,
                                 text: $text)
                .padding()
            }
            
            chooseLocationFilterBar

            gridView
            
            Spacer()
            
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Choose Location")
                    .font(.title.bold())
            }
        }
    }
    
    var chooseLocationFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack() {
                ForEach(ChooseLocationFilterViewModel.allCases, id: \.rawValue) { item in
                    VStack {
                        Text(item.title)
                            .font(.subheadline)
//                            .fontWeight(selectedFilter == item ? .semibold : .regular)
                            .foregroundColor(selectedFilter == item ? Color(UIColor.label) : .gray)
                        
                        if selectedFilter == item {
                            Capsule()
                                .foregroundColor(Color(.systemBlue))
                                .frame(height: 3)
                                .matchedGeometryEffect(id: "filter", in: animation)
                            
                        } else {
                            Capsule()
                                .foregroundColor(Color(.clear))
                                .frame(height: 3)
                        }
                        
                    }
                    .padding(.horizontal)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            self.selectedFilter = item
                        }
                    }
                }
            }
            .overlay(Divider().offset(x: 0, y: 16))
        }
    }
    
    var gridView: some View {
        Text("Yuh")
    }
}

struct ChooseLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseLocationView()
    }
}
