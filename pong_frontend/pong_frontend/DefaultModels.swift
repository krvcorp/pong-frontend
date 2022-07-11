//
//  DefaultModels.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation

var default_post = Post(id: "DefaultId",
                        user: "DefaultUser",
                        title: "DefulatTitle",
                        image: "",
                        createdAt: "DefaultDate",
                        updatedAt: "DefaultDate",
                        numComments: -1,
                        comments: [],
                        score: -1,
                        timeSincePosted: "DefaultString")

var default_comment = Comment(id: "DefaultID",
                              user: "DefaultUser",
                              post: -1,
                              comment: "Default comment",
                              created_at: "Default Date",
                              updated_at: "Default Date",
                              score: -1)
