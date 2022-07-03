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
    var columns = Array(repeating: GridItem(.fixed(UIScreen.main.bounds.size.width/2)), count: 2)
    
    
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
            ScrollViewReader { scrollReader in
                HStack() {
                    ForEach(ChooseLocationFilterViewModel.allCases, id: \.rawValue) { item in
                        VStack {
                            Text(item.title)
                                .font(.subheadline)
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
                .onChange(of: selectedFilter, perform: { value in
                    print("DEBUG: selectedFilter Changed")
                    print("DEBUG: \(value)")
                    withAnimation{
                        scrollReader.scrollTo(value.rawValue, anchor: .center)
                    }
                })
            }
        }
    }
    
    var gridView: some View {
        TabView(selection: $selectedFilter) {
            ForEach(ChooseLocationFilterViewModel.allCases, id: \.self) { view in
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 30) {
                        ForEach(ChooseLocationViewModel.allCases, id: \.rawValue) { viewModel in
                            Button {
                                print("DEBUG: Choose \(viewModel.title)")
                            } label: {
                                VStack {
                                    VStack {
                                        Text("\(viewModel.title)")
                                        }
                                    }
                                }
                                .frame(minWidth: 0, maxWidth: UIScreen.main.bounds.size.width/3, minHeight: UIScreen.main.bounds.size.width/5)
                                .font(.system(size: 18).bold())
                                .padding()
                                .foregroundColor(Color(UIColor.label))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(UIColor.secondaryLabel), lineWidth: 10))
                            }
                            // remove highlight on tap
                            .background(Color(UIColor.systemBackground)) // If you have this. change to background of school?
                            .cornerRadius(20)         // You also need the cornerRadius here
                    }
                }.tag(view.rawValue) // by having the tag be the enum's raw value,
                // you can always compare enum to enum.
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct ChooseLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseLocationView()
    }
}
