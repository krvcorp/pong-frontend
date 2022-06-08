//
//  Post.swift
//  SidechatMockup
//
//  Created by Khoi Nguyen on 6/5/22.
//

import Foundation

struct Post: Identifiable, Codable {
    var id: String
    var user: String
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var expanded: Bool
}
