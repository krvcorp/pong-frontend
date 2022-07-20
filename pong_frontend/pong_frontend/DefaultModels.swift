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
                        numComments: -1,
                        comments: [],
                        score: -1,
                        timeSincePosted: "DefaultString")

var defaultComment = Comment(id: "DefaultID",
                             post: "DefaultPostID",
                             user: "DefaultUser",
                              comment: "Default comment",
                              createdAt: "Default Date",
                              updatedAt: "Default Date",
                              score: -1,
                             timeSincePosted: "Default Time Since Posted")
