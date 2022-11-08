//
//  PollView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/30/22.
//

import SwiftUI

struct PollView: View {
    let pollOptionFrame : CGFloat = CGFloat(UIScreen.screenWidth - 25)
    @Binding var post : Post
    @StateObject var pollVM = PollViewModel()
    
    // MARK: Body
    var body: some View {
        PollOptionContainer
            .onChange(of: pollVM.poll) {
                self.post.poll = $0
            }
    }
    
    // MARK: MinDivision
    /// Calculates the minimum length of the colored poll bar
    func minDivision(first: CGFloat, second: CGFloat) -> CGFloat {
        if first / second > 0.09 {
            return first/second
        }
        else {
            return 0.09
        }
    }
    
    // MARK: PollOptionContainer
    var PollOptionContainer: some View {
        VStack {
            ForEach(post.poll!.options, id: \.self) { option in
                // MARK: User has voted
                if post.poll!.userHasVoted {
                // do not display skip button as an option
                    VStack(spacing: 0) {
                        HStack {
                            Text("\(option.title)")
                                .font(.headline)
                                .padding(4)
                            
                            Spacer()
                            
                            Text("\(option.numVotes) votes")
                                .font(.caption)
                        }
                        .frame(width: pollOptionFrame)
                        .foregroundColor(Color(UIColor.label))
                        
                        // color on color piece
                        ZStack(alignment: .leading) {
                            // background gray
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.pongSecondarySystemBackground)
                                .frame(width: pollOptionFrame)
                                .opacity(0.5)
                            
                            // overlay color
                            RoundedRectangle(cornerRadius: 20)
                                .fill(post.poll!.votedFor == option.id ? Color.green : Color.pongAccent)
                                .frame(width: pollOptionFrame * minDivision(first: CGFloat(option.numVotes), second: CGFloat(pollVM.sumVotes(poll: post.poll!))))
                        }
                        .padding(.top, 5)
                        .frame(height: 15)
                    }
                    .padding(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(post.poll!.votedFor == option.id ? Color.green : Color.clear, lineWidth: 1))
                }
                
                // MARK: User has not voted
                else {
                    // do not display skip button as an option
                    if option.title != "skipkhoicunt" {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            pollVM.pollVote(id: option.id, postId: post.id)
                        } label: {
                            HStack {
                                Text("\(option.title)")
                                    .font(.headline)
                                    .padding(4)
                                
                                Spacer()
                                
                            }
                            .padding(5)
                            .padding(.horizontal, 10)
                            .frame(width: pollOptionFrame)
                            .foregroundColor(Color(UIColor.label))
                            .background(
                                // rectangle with corner radius 5 and shadow with opacity .5
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.pongSystemBackground)
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 0)
                                )
                        }
                    }
                }
            }
            
            // MARK: The bottom of the thing
            HStack {
                // check if the user hasn't voted
                if !post.poll!.userHasVoted {
                    // add skip button if it exists
                    if let skip = post.poll!.skip {
                        Button {
                            pollVM.pollVote(id: skip.id, postId: post.id)
                        } label: {
                            Text("Skip voting")
                                .font(.caption.bold())
                        }
                        .foregroundColor(Color.pongAccent)
                    }
                }
                // if user has voted
                else {
                    // display skipped number if it exists
                    if let skip = post.poll!.skip {
                        Text("\(skip.numVotes) skipped voting")
                            .font(.caption.bold())
                    }
                }

                Spacer()
                
                Text("\(pollVM.sumVotes(poll: post.poll!)) votes")
                    .font(.caption)
            }
            .padding()
        }
    }
}
