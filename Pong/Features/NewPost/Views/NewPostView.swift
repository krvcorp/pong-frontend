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
    
    // MARK: image uploader
    @State private var showSheet = false

    // MARK: new poll
    @State private var showNewPoll = false
    
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
                        TextArea("What's on your mind?", text: $newPostVM.title)
                            .font(.title)
                        
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
                                    showNewPoll = false
                                    newPostVM.newPollVM.reset()
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
                                    showNewPoll.toggle()
                                    newPostVM.image = nil
                                    newPostVM.newPollVM.reset()
                                } label: {
                                    Image(systemName: "chart.bar")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.secondary)
                                }

                                
                                Spacer()
                                Text("\(newPostVM.characterLimit - newPostVM.title.count)")
                                    .foregroundColor(newPostVM.characterLimit - newPostVM.title.count <= 30 ? .red : Color(UIColor.label))
                            }
                            .padding()
                            .frame(minHeight: 25, maxHeight: 60)

                            // MARK: On success of newPost, NewPostView needs to dismiss to reset data in NewPost
                            Button {
                                newPostVM.newPost()
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
