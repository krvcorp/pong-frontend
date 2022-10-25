import SwiftUI
import AlertToast

@main
struct Pong: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
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
