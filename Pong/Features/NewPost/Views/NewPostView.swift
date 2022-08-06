//
//  NewPostView.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/6/22.
//

import SwiftUI
import Combine
import PopupView

struct NewPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var newPostVM = NewPostViewModel()
    
    // local logic shit
    @State private var text = ""
    @State private var max_lim = 180
    
    // image uploader
    @State private var showSheet = false
    @State private var image = UIImage()

    // new poll
    @State private var showNewPoll = false
    
    // tracks scroll to top of recent posts
//    @Binding var newPost: Bool
    
    func limitText(_ upper: Int) {
        if text.count > upper {
            text = String(text.prefix(upper))
        }
    }
    
    var body: some View {
        ZStack {
            ZStack (alignment: .bottom) {
                VStack {
                    
                    ScrollView {
                        TextArea("What's on your mind?", text: $text)
                        .onReceive(Just(text)) { _ in limitText(max_lim) }
                        
                        if image != UIImage() {
                            ZStack(alignment: .topLeading) {

                                Image(uiImage: self.image)
                                    .resizable()
                                    .scaledToFit()
                                    
                                Button {
                                    image = UIImage()
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .frame(width: 35, height: 35)
                                .foregroundColor(.primary)
                                .background(Circle().fill(.secondary).opacity(0.6))
                                .padding()
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            .padding()
                        }
                        if showNewPoll == true {
                            NewPoll(showNewPoll: $showNewPoll)
                        }
                        
                    }
                    
                    Spacer()
                    
                    ZStack {
                        VStack {
                            HStack {
                                Button {
                                    showSheet = true
                                } label: {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.secondary)
                                }
                                .sheet(isPresented: $showSheet) {
                                    ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                                }
                                .padding(.trailing)

                                
                                Button {
                                    print("DEBUG: showNewPoll")
                                    showNewPoll.toggle()
                                } label: {
                                    Image(systemName: "chart.bar")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.secondary)
                                }

                                
                                Spacer()
                                Text("\(max_lim - text.count)")
                            }
                            .padding()
                            .frame(minHeight: 25, maxHeight: 60)

                            Button {
                                print("DEBUG: New post")
                                newPostVM.newPost(title: text) { result in
                                    switch result {
                                    case .success(let response):
                                        print("DEBUG: \(response)")
                                    case .failure(let error):
                                        print("DEBUG: newPostVM.newPost completion error \(error)")
                                    }
                                }
                                // accessing postVM too quickly here ? can't perform dismiss inside completion
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    if !newPostVM.error {
//                                        newPost = true
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            } label: {
                                Text("Post")
                                    .frame(minWidth: 100, maxWidth: 150)
                                    .font(.system(size: 18).bold())
                                    .padding()
                                    .foregroundColor(Color(UIColor.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.primary, lineWidth: 2)
                                )
                            }
                            .background(Color(UIColor.label)) // If you have this
                            .cornerRadius(20)         // You also need the cornerRadius here
                        .padding(.bottom)
                        }
                    }
                }
            }
        }
        .popup(isPresented: $newPostVM.error, type: .floater(), position: .top, animation: .spring(), autohideIn: 3) {
            FloatWarning(message: "Slow down!")
        }
    }
}
