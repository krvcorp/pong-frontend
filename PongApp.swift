import SwiftUI
import AlertToast

@main
struct Pong: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .dynamicTypeSize(.medium ... .medium)
                .onAppear() {
                    SettingsViewModel.shared.displayMode.setAppDisplayMode()
                }
        }
    }
}
