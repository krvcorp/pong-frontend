//
//  ChatView.swift
//  ChatExample
//
//  Created by Kino Roy on 2020-07-18.
//  Copyright © 2020 MessageKit. All rights reserved.
//

import MessageKit
import SwiftUI

struct MessageView: View {
    @Binding var conversation: Conversation
    @StateObject var messageVM : MessageViewModel = MessageViewModel()
//    @ObservedObject var messageRosterVM : MessageRosterViewModel

    var body: some View {
        // MARK: MessagesView can only take messages that conform to MesssageKit API
        MessagesView(messages: $messageVM.messageKitMessages, messageVM: messageVM)
            // onAppear load binding conversation into viewmodel
            .onAppear {
                self.messageVM.conversation = conversation
                self.messageVM.ourMessageAPIToMessageKitAPI(messages: conversation.messages)
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarTitle("\(conversation.re)", displayMode: .inline)
        
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
                self.messageVM.timer = Timer.publish (every: 1, on: .current, in: .common).autoconnect()
            }
            .onDisappear {
                self.messageVM.timer.upstream.connect().cancel()
            }
            // action to do on update of conversation model
            .onChange(of: messageVM.messageUpdateTrigger) { newValue in
                print("DEBUG: messageUpdateTrigger")
                if self.conversation.messages != messageVM.conversation.messages {
                    self.conversation.messages = messageVM.conversation.messages
                    self.messageVM.ourMessageAPIToMessageKitAPI(messages: conversation.messages)
                }
            }
    }
}
