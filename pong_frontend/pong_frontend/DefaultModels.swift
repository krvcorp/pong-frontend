//
//  DefaultModels.swift
//  pong_frontend
//
//  Created by Khoi Nguyen on 6/9/22.
//

import Foundation

var default_post = Post(id: -1,
                        user: -1,
                        title: "Default Title",
                        created_at: "Default Date",
                        updated_at: "Default Date")

var default_comment = Comment(id: -1,
                              post: -1,
                              user: -1,
                              comment: "Default comment",
                              created_at: "Default Date",
                              updated_at: "Default Date")
