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
                             saved: false,
                             imageHeight: 0,
                             imageWidth: 0)

var defaultProfileComment = ProfileComment(id: "default",
                                           re: "default",
                                           rePostId: "default",
                                           comment: "default",
                                           score: 0,
                                           timeSincePosted: "default",
                                           voteStatus: 0)

var defaultPoll = Poll(id: "default",
                       userHasVoted: false,
                       votedFor: "default",
                       options: [],
                       skip: defaultSkip)

var defaultMessage = Message(id: "default",
                             message: "default",
                             createdAt: "now",
                             userOwned: true)

var defaultConversation = Conversation(id: "default",
                                       messages: [defaultMessage],
                                       re: "default",
                                       reTimeAgo: "default",
                                       unreadCount: 1,
                                       postId: "default",
                                       timeSinceUpdated: "1h")

var defaultSkip = Poll.Skip(enabled: true, numVotes: 0, id: "default")
