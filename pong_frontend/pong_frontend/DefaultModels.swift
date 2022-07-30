//
//  DefaultModels.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation

var defaultPost = Post(id: "DefaultId",
                       user: "DefaultUser",
                       title: "DefulatTitle",
                       image: "",
                       createdAt: "DefaultDate",
                       updatedAt: "DefaultDate",
                       saved: false,
                       flagged: false,
                       blocked: false,
                       numComments: -1,
                       comments: [],
                       score: -1,
                       timeSincePosted: "DefaultString",
                       voteStatus: 0)

var defaultComment = Comment(id: "default",
                             post: "default",
                             user: "default",
                             comment: "default",
                             createdAt: "default",
                             updatedAt: "default",
                             score: 0,
                             timeSincePosted: "default",
                             parent:"default",
                             children: [],
                             numberOnPost: 1)

var defaultTotalScore = TotalScore(score: 1, place:"1")
