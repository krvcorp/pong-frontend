//
//  PollView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/30/22.
//

import SwiftUI

struct PollView: View {
    @Binding var post : Post
    @StateObject var pollVM = PollViewModel()
    
    var body: some View {
        PollOptionContainer
            .onChange(of: pollVM.poll) {
                self.post.poll = $0
            }
    }
    
    var PollOptionContainer: some View {
        VStack {
            ForEach(post.poll!.options, id: \.self) { option in
                // MARK: User has voted
                if post.poll!.userHasVoted {
                    HStack {
                        Text("\(option.title)")
                            .font(.headline)
                            .padding(4)
                        Spacer()
                        Text("\(option.numVotes) votes")
                    }
                    .padding(5)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(.black)
                    .background(post.poll!.votedFor == option.id ? Color.poshGold : Color.bone)
                    .cornerRadius(5)         // You also need the cornerRadius here
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.darkGray), lineWidth: 2))
                    .padding(.top, 5)
                }
                // MARK: User has not voted, can still vote
                else {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        print("DEBUG: Tap to vote \(option.title)")
                        pollVM.pollVote(id: option.id, postId: post.id)
                    } label: {
                        HStack {
                            Text("\(option.title)")
                                .font(.headline)
                                .padding(4)
                            Spacer()
                        }
                        .padding(5)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .foregroundColor(.black)
                        .background(Color.bone)
                        .cornerRadius(5)         // You also need the cornerRadius here
                    }
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.darkGray), lineWidth: 2))
                    .padding(.top, 5)
                }
            }
            
            HStack {
                Spacer()
                Text("\(pollVM.sumVotes(poll: post.poll!)) votes")
                    .font(.caption)
            }
        }
    }
}

struct PollView_Previews: PreviewProvider {
    static var previews: some View {
        PollView(post: .constant(defaultPost))
    }
}
