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
                       image: "",
                       numComments: 0,
                       score: 0,
                       timeSincePosted: "default",
                       voteStatus: 0,
                       saved: false,
                       flagged: false,
                       blocked: false,
                       numUpvotes: 0,
                       numDownvotes: 0)

var defaultComment = Comment(id: "default",
                             post: "default",
                             comment: "default",
                             createdAt: "default",
                             updatedAt: "default",
                             score: 0,
                             timeSincePosted: "default",
                             parent: "",
                             children: [],
                             numberOnPost: 0)

var defaultTotalScore = TotalScore(score: 1, place:"1")
