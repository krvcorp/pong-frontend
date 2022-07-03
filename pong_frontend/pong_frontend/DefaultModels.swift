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
                        created_at: "DefaultDate",
                        updated_at: "DefaultDate",
                        num_comments: -1,
                        comments: [],
                        total_score: -1)

var default_comment = Comment(id: -1,
                              post: -1,
                              user: -1,
                              comment: "Default comment",
                              created_at: "Default Date",
                              updated_at: "Default Date",
                              total_score: -1)
