//
//  SettingsSheetViewModel.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import Foundation

@MainActor class SettingsSheetViewModel: ObservableObject {
    @Published var showSettingsSheetView = false
    @Published var showLegalSheetView = false
    @Published var showAccountSheetView = false
}
