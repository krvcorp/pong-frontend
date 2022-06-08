//
//  NewPostView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/6/22.
//

import SwiftUI

struct NewPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var text = ""
    
    var body: some View {
        ZStack (alignment: .bottom) {
            VStack {
                TextArea("What's on your mind?", text: $text)
                
                Spacer()
                
                ZStack {
                    VStack {
                        HStack {
                            Button {
                                print("DEBUG: Photos")
                            } label: {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.black)
                            }
                            .padding(.trailing)

                            
                            Button {
                                print("DEBUG: Poll")
                            } label: {
                                Image(systemName: "chart.bar")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.black)
                            }

                            
                            Spacer()
                            Text("0")
                        }
                        .padding()
                        .frame(minHeight: 25, maxHeight: 60)
                        
                        Button {
                            print("DEBUG: Post")
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Post")
                                .frame(minWidth: 100, maxWidth: 150)
                                .font(.system(size: 18).bold())
                                .padding()
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white, lineWidth: 2)
                            )
                        }
                        .background(Color.black) // If you have this
                        .cornerRadius(20)         // You also need the cornerRadius here
                    .padding(.bottom)
                    }
                }
            }
            .toolbar{
                ToolbarItem(placement: .principal) {
                    Text("New Post")
                        .font(.title.bold())
                }
            }
        .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView()
    }
}