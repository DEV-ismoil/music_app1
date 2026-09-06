import SwiftUI

@main
struct GrooveApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .ignoresSafeArea()
                .persistentSystemOverlays(.hidden)
        }
    }
}
