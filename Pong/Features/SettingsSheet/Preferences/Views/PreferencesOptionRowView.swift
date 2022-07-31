//
//  PreferencesOptionRowView.swift
//  Pong
//
//  Created by Khoi Nguyen on 7/25/22.
//

import SwiftUI

struct PreferencesOptionRowView: View {
    let preferencesSettingsEnum: PreferencesSettingsEnum
    
    // DARK MODE STUFF
    enum DisplayMode: Int {
        case system, dark, light
        
        func setAppDisplayMode() {
            var userInterfaceStyle: UIUserInterfaceStyle
            switch self {
                case .system: userInterfaceStyle = .unspecified
                case .dark: userInterfaceStyle = .dark
                case .light: userInterfaceStyle = .light
            }
            
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            scene?.keyWindow?.overrideUserInterfaceStyle = userInterfaceStyle
        }
    }
    
    @AppStorage("displayMode") var displayMode = DisplayMode.system
    
    var body: some View {
        VStack {
            HStack {
                Text("Display mode")
                    .font(.subheadline.bold())
                Picker("Is Dark?", selection: $displayMode) {
                    Text("System").tag(DisplayMode.system)
                    Text("Dark").tag(DisplayMode.dark)
                    Text("Light").tag(DisplayMode.light)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: displayMode) { newValue in
                    displayMode.setAppDisplayMode()
                }
                Spacer()
            }
            .frame(height: 40)
            .padding(.leading)

            Divider()
        }
        .background(Color(UIColor.secondarySystemBackground)) // necessary for clickable background
    }
}

struct PreferencesOptionRowView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesOptionRowView(preferencesSettingsEnum: .displayModeSetting)
    }
}
