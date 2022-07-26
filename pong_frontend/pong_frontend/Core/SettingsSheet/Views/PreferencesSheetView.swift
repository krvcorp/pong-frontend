//
//  PreferencesSheetView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import SwiftUI

struct PreferencesSheetView: View {
    @ObservedObject var settingsSheetVM: SettingsSheetViewModel
    
    var body: some View {
        ActionSheetView(bgColor: Color(UIColor.secondarySystemBackground)) {
            VStack {
                // HEADER
                ZStack {
                    HStack() {
                        Button {
                            print("DEBUG: PreferencesSheetView Back")
                            settingsSheetVM.showSettingsSheetView = true
                            settingsSheetVM.showPreferencesSheetView = false
                        } label: {
                            BackButton()
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Text("Preferences")
                        .font(.title.bold())
                }
                // BODY
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {

                        // Preferences
                        HStack {
                            Text("Preferences")
                                .font(.headline.bold())
                            Spacer()
                        }
                        ForEach(PreferenceSettingsEnum.allCases, id: \.rawValue) { preferenceSettingsEnum in
                            PreferencesOptionRowView(preferenceSettingsEnum: preferenceSettingsEnum)
                        }
                        
                        // Notifications
                        HStack {
                            Text("Notifications")
                                .font(.headline.bold())
                            Spacer()
                        }
                        ForEach(NotificationSettingsEnum.allCases, id: \.rawValue) { notificationSettingsEnum in
                            
                        }
                        Spacer()
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct PreferencesSheetView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesSheetView(settingsSheetVM: SettingsSheetViewModel())
    }
}
