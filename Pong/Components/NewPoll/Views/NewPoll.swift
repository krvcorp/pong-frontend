//
//  NewPoll.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/31/22.
//

import SwiftUI

struct NewPoll: View {
    @Binding var showNewPoll : Bool
    @State var allowSkipVoting : Bool = false
    
    var body: some View {
        VStack {
            PollOptionContainer
            
            HStack {
                Toggle(isOn: $allowSkipVoting) {
                    Text("Allow Skip Voting")
                        .font(.caption.bold())
                        .foregroundColor(Color(UIColor.label))
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                
                Button {
                    showNewPoll.toggle()
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
    
    var PollOptionContainer: some View {
        Text("Your future poll object!")
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
        NewPoll(showNewPoll: .constant(false))
    }
}
