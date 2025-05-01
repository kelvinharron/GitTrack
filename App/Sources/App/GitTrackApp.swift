import AppKit
import AuthenticationServices
import SwiftUI

@main
struct GitTrackApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(appState)
    }
}
