//
//  DefaultModels.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation

var defaultPost = Post(id: "default",
                       title: "default",
                       createdAt: "default",
                       updatedAt: "default",
                       image: nil,
                       numComments: 0,
                       score: 0,
                       timeSincePosted: "default",
                       voteStatus: 0,
                       saved: false,
                       flagged: false,
                       blocked: false,
                       numUpvotes: 0,
                       numDownvotes: 0,
                       userOwned: true,
                       poll: nil)

var defaultComment = Comment(id: "default",
                             post: "default",
                             comment: "default",
                             createdAt: "default",
                             updatedAt: "default",
                             score: 0,
                             timeSincePosted: "default",
                             parent: "",
                             children: [],
                             numberOnPost: 0,
                             userOwned: true,
                             voteStatus: 0,
                             numUpvotes: 0,
                             numDownvotes: 0)

var defaultProfileComment = ProfileComment(id: "default",
                                           re: "default",
                                           rePostId: "default",
                                           comment: "default",
                                           score: 0,
                                           timeSincePosted: "default",
                                           voteStatus: 0,
                                           numUpvotes: 0,
                                           numDownvotes: 0)

//var defaultTotalScore = TotalScore(score: 1, place:"1")

var defaultPoll = Poll(id: "default", userHasVoted: false, votedFor: "default", options: [])

var defaultConversation = Conversation(id: "default", messages: [defaultMessage], re: "default", read: true, timeSinceUpdated: "yesterday")

var defaultMessage = Message(id: "default", message: "default", createdAt: "now", userOwned: true)
