//
//  MessageRosterViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 9/11/22.
//

import MessageKit
import SwiftUI
import Foundation

class MessageRosterViewModel: ObservableObject {
//    @Published var conversations : [Conversation] = []
    var timePassed = 0
    var timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    // MARK: Polling here
    func getConversations(dataManager : DataManager) {
        NetworkManager.networkManager.request(route: "conversations/", method: .get, successType: [Conversation].self) { successResponse, errorResponse in
            if let successResponse = successResponse {
                DispatchQueue.main.async {
                    if dataManager.conversations != successResponse {
                        dataManager.conversations = successResponse
                    }
                }
            }
        }
    }
    
    func stringToDateToString(dateString : String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        let date = dateFormatter.date(from: dateString)!
        let dateToStringFormatter = DateFormatter()
        
        if Calendar.current.isDateInToday(date) {
            // return time
            dateToStringFormatter.timeStyle = .short
            let dateToDisplay = dateToStringFormatter.string(from: date)
            return dateToDisplay
        } else if Calendar.current.isDateInYesterday(date) {
            // return yesterday string
            return "Yesterday"
        } else {
            // return short date format
            dateToStringFormatter.dateStyle = .short
            let dateToDisplay = dateToStringFormatter.string(from: date)
            return dateToDisplay
        }
    }
}

