//
//  NewPoll.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/31/22.
//

import SwiftUI
import Combine

struct NewPoll: View {
    @Binding var showNewPoll : Bool
    @ObservedObject var newPollVM : NewPollViewModel
    
    var body: some View {
        VStack {
            PollOptionContainer
            
            HStack {
                Toggle(isOn: $newPollVM.allowSkipVoting) {
                    Text("Allow Skip Voting")
                        .font(.caption.bold())
                        .foregroundColor(Color(UIColor.label))
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showNewPoll.toggle()
                    newPollVM.reset()
                } label: {
                    Text("Remove Poll")
                        .font(.caption.bold())
                        .foregroundColor(Color(UIColor.systemGray))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .padding()
    }
    
    // MARK: Six options
    var PollOptionContainer: some View {
        VStack {
            ForEach(0..<newPollVM.pollOptions.count, id: \.self) { i in
                HStack {
                    TextField("Option \(i + 1)", text: $newPollVM.pollOptions[i])
                        .onReceive(Just(newPollVM.pollOptions[i]), perform: { change in
                            newPollVM.limit(index: i)
                        })
                        .font(.title3)
                        .padding(5)
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.pongSecondaryText, lineWidth: 1))
                    
                    Spacer()
                    
                    if newPollVM.pollOptions.count > 2 {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            newPollVM.pollOptions.remove(at: i)
                        } label: {
                            Image(systemName: "delete.left")
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.top, 8)
            }
            
            if newPollVM.pollOptions.count < 6 {
                HStack {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        newPollVM.pollOptions.append("")
                    } label: {
                        HStack {
                            Text("ADD OPTION")
                        }
                        .padding(8)
                        .foregroundColor(Color.pongAccent)
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .font(.system(size: 18).bold())
    }
}

struct NewPoll_Previews: PreviewProvider {
    static var previews: some View {
        NewPoll(showNewPoll: .constant(false), newPollVM: NewPollViewModel())
    }
}
