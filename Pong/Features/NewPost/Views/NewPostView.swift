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
    @Binding var isCustomItemSelected : Bool
    
    // MARK: local logic shit
    @State private var text = ""
    @State private var max_lim = 180
    
    // MARK: image uploader
    @State private var showSheet = false

    // MARK: new poll
    @State private var showNewPoll = false
    
    func limitText(_ upper: Int) {
        if text.count > upper {
            text = String(text.prefix(upper))
        }
    }
    
    var body: some View {
        ZStack {
            ZStack (alignment: .bottom) {
                VStack {
                    Button {
                        print("DEBUG: \(isCustomItemSelected)")
                        isCustomItemSelected.toggle()
                    } label: {
                        Text("Dismiss")
                    }
                    ScrollView {
                        TextArea("What's on your mind?", text: $text)
                        .onReceive(Just(text)) { _ in limitText(max_lim) }
                        
                        if newPostVM.image != nil {
                            ZStack(alignment: .topLeading) {

                                Image(uiImage: self.newPostVM.image!)
                                    .resizable()
                                    .scaledToFit()
                                    
                                Button {
                                    newPostVM.image = nil
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .frame(width: 35, height: 35)
                                .foregroundColor(.white)
                                .background(Circle().fill(.black).opacity(0.6))
                                .padding()
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            .padding()
                        }
                        
                        if showNewPoll == true {
                            NewPoll(showNewPoll: $showNewPoll, newPollVM: newPostVM.newPollVM)
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        VStack {
                            HStack {
                                // MARK: Image picker
                                Button {
                                    showSheet = true
                                } label: {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.secondary)
                                }
                                .sheet(isPresented: $showSheet) {
                                    ImagePicker(sourceType: .photoLibrary, selectedImage: self.$newPostVM.image)
                                }
                                .padding(.trailing)

                                // MARK: Poll generator
                                Button {
                                    print("DEBUG: toggle showNewPoll")
                                    showNewPoll.toggle()
                                    newPostVM.newPollVM.reset()
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
                                newPostVM.newPost(title: text)
                                newPostVM.newPollVM.reset()
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
    }
}
