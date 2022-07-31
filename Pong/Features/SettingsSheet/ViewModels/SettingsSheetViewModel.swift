//
//  SettingsSheetViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import Foundation
import SwiftUI

class SettingsSheetViewModel: ObservableObject {
    @Published var showSettingsSheetView = false
    @Published var showAccountSheetView = false
    @Published var showPreferencesSheetView = false
    @Published var showNotificationsSheetView = false
    @Published var showLegalSheetView = false
    @Published var showDeleteAccountConfirmationView = false
}
