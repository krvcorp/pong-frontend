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
    @ObservedObject var messageRosterVM : MessageRosterViewModel

    var body: some View {
        // MARK: MessagesView can only take messages that conform to MesssageKit API
        MessagesView(messages: $messageVM.messageKitMessages, messageVM: messageVM)
            .onAppear {
                self.messageVM.conversation = conversation
                self.messageVM.ourMessageAPIToMessageKitAPI(messages: conversation.messages)
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarTitle("\(conversation.re)", displayMode: .inline)
            .onReceive(messageRosterVM.timer) { _ in
                if messageRosterVM.timePassed % 5 != 0 {
//                    print("DEBUG: one second")
                    messageRosterVM.timePassed += 1
                }
                else {
                    // poll here
                    print("DEBUG: pollConversations")
                    messageRosterVM.getConversations()
                    messageRosterVM.timePassed += 1
                }
            }
            .onAppear {
                print("DEBUG: onAppear")
                self.messageRosterVM.insideMessageView = true
                self.messageRosterVM.timer = Timer.publish (every: 1, on: .current, in: .common).autoconnect()
            }
            .onDisappear {
                print("DEBUG: onDisappear")
                self.messageRosterVM.insideMessageView = false
                self.messageRosterVM.timer.upstream.connect().cancel()
            }
        }

    // MARK: Private
    }


