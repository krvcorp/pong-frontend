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
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray), lineWidth: 2))
                    
                    Spacer()
                    
                    if newPollVM.pollOptions.count > 2 {
                        Button {
                            print("DEBUG: Remove row")
                            newPollVM.pollOptions.remove(at: i)
                        } label: {
                            Image(systemName: "delete.left")
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.top, 5)
            }
            
            if newPollVM.pollOptions.count < 6 {
                Button {
                    print("DEBUG: Add Option")
                    newPollVM.pollOptions.append("")
                    print("DEBUG: \(newPollVM.pollOptions)")
                } label: {
                    Text("Add")
                        .foregroundColor(.green)
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .font(.system(size: 18).bold())
        .padding()
        .foregroundColor(Color(UIColor.label))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(UIColor.systemGray), lineWidth: 5))
        .background(Color(UIColor.systemBackground)) // If you have this
        .cornerRadius(10)         // You also need the cornerRadius here
    }
}

struct NewPoll_Previews: PreviewProvider {
    static var previews: some View {
        NewPoll(showNewPoll: .constant(false), newPollVM: NewPollViewModel())
    }
}
