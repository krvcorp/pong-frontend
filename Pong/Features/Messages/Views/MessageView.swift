//
//  ChatView.swift
//  ChatExample
//
//  Created by Kino Roy on 2020-07-18.
//  Copyright © 2020 MessageKit. All rights reserved.
//

//import MessageKit
import SwiftUI

struct MessageView: View {
    @State private var text = ""
    @Binding var conversation: Conversation
    @StateObject var messageVM : MessageViewModel = MessageViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(messageVM.conversation.messages, id: \.self) { message in
                    if message.userOwned {
                        HStack {
                            Spacer()
                            HStack {
                                Text("\(message.message)")
                                    .font(.headline)
                                    .padding()
                            }
                            .foregroundColor(Color(UIColor.label))
                            .background(Color.pongSystemBackground)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.darkGray), lineWidth: 1))
                        }
                        .listRowSeparator(.hidden)
                    } else {
                        HStack {
                            HStack {
                                Text("\(message.message)")
                                    .font(.headline)
                                    .padding()
                            }
                            .foregroundColor(Color(UIColor.label))
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.darkGray), lineWidth: 1))
                            
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .padding(.bottom, 50)
            
            MessageComponent
        }
        .background(Color.pongSystemBackground)
        // onAppear load binding conversation into viewmodel
        .onAppear {
            self.messageVM.conversation = conversation
        }
        .navigationBarTitle("\(conversation.re)", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    messageVM.showBlockConfirmationView = true
                } label: {
                    Image(systemName: "person.fill.badge.minus")
                        .foregroundColor(Color(UIColor.label))
                }
            }
        }
        // MARK: Delete Confirmation
        .alert(isPresented: $messageVM.showBlockConfirmationView) {
            Alert(
                title: Text("Block user"),
                message: Text("Are you sure you want to block this user?"),
                primaryButton: .destructive(Text("Block")) {
                    messageVM.blockUser() { success in
                        self.presentationMode.wrappedValue.dismiss()
                    }
                },
                secondaryButton: .cancel()
            )
        }

        // logic to start/stop polling
        .onReceive(messageVM.timer) { _ in
            if messageVM.timePassed % 5 != 0 {
                messageVM.timePassed += 1
            }
            else {
                messageVM.getConversation()
                messageVM.timePassed += 1
            }
        }
        .onAppear {
            self.messageVM.conversation.read = true
            self.messageVM.readConversation()
            self.messageVM.timer = Timer.publish (every: 1, on: .current, in: .common).autoconnect()
        }
        .onDisappear {
            self.messageVM.timer.upstream.connect().cancel()
        }
        // action to do on update of conversation model
        .onChange(of: messageVM.messageUpdateTrigger) { newValue in
            if self.conversation.messages != messageVM.conversation.messages {
                print("DEBUG: message written")
                self.messageVM.scrolledToBottom = false
                self.conversation.messages = messageVM.conversation.messages
                print("DEBUG: \(self.conversation.messages)")
            }
        }
    }
    
    var MessageComponent : some View {
        VStack(spacing: 0) {
            
            // MARK: Messaging Component
            VStack {
                // MARK: TextArea and Button Component
                HStack {
                    TextField("Enter your message here", text: $text)
                        .font(.headline)
                        
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        print("DEBUG SEND MESSAGE")
                    } label: {
                        ZStack {
                            Image(systemName: "paperplane")
                                .imageScale(.small)
                                .foregroundColor(Color(UIColor.label))
                                .font(.largeTitle)
                        }
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 3)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.secondarySystemBackground), lineWidth: 2))
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20, corners: [.topLeft, .topRight])
        }
        .shadow(color: Color(.black).opacity(0.3), radius: 10, x: 0, y: 0)
        .mask(Rectangle().padding(.top, -20))
    }
}
