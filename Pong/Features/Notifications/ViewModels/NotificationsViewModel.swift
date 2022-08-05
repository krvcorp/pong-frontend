//
//  NotificationsViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 8/5/22.
//

import Foundation

enum NotificationsFilter: String, CaseIterable, Identifiable {
    case messages, postsAndComments
    var id: Self { self }
}

class NotificationsViewModel: ObservableObject {
    @Published var selectedNotificationsFilter : NotificationsFilter = .messages
}
