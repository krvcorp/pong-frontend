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
                    if option.title != "skipkhoicunt" {
                        ZStack(alignment: .leading) {
                            HStack {
                                Text("\(option.title)")
                                    .font(.headline)
                                    .padding(4)
                                
                                Spacer()
                                
                                Text("\(option.numVotes) votes")
                                    .font(.caption)
                            }
                            .padding(5)
                            .padding(.horizontal, 10)
                            .frame(width: CGFloat(UIScreen.screenWidth - 20))
                            .foregroundColor(Color(UIColor.label))
                            .background(post.poll!.votedFor == option.id ? SchoolManager.shared.schoolPrimaryColor() : Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)         // You also need the cornerRadius here
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(UIColor.darkGray), lineWidth: 1))

                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: CGFloat(UIScreen.screenWidth - 20) * (CGFloat(option.numVotes) / CGFloat(pollVM.sumVotes(poll: post.poll!))))
                                .opacity(0.5)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.top, 5)
                    }
                }
                // MARK: User has not voted, can still vote
                else {
                    if option.title != "skipkhoicunt" {
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
                            .frame(width: CGFloat(UIScreen.screenWidth - 20))
                            .foregroundColor(Color(UIColor.label))
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)         // You also need the cornerRadius here
                        }
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(UIColor.darkGray), lineWidth: 1))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.top, 5)
                    }
                }
            }
            
            HStack {
                if !post.poll!.userHasVoted {
                    if let skipOption = post.poll!.options.first(where: {$0.title == "skipkhoicunt"}) {
                        Button {
                            pollVM.pollVote(id: skipOption.id, postId: post.id)
                        } label: {
                            Text("Skip voting")
                                .font(.caption.bold())
                        }
                    }
                } else {
                    if let skipOption = post.poll!.options.first(where: {$0.title == "skipkhoicunt"}) {
                        Text("\(skipOption.numVotes) skipped voting")
                            .font(.caption.bold())
                    }
                }

                Spacer()
                
                Text("\(pollVM.sumVotes(poll: post.poll!)) votes")
                    .font(.caption)
            }
            .padding(.top, 2)
            .padding(.bottom)
        }
    }
}

struct PollView_Previews: PreviewProvider {
    static var previews: some View {
        PollView(post: .constant(defaultPost))
    }
}
