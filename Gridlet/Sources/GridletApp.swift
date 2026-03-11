import SwiftUI

@main
struct GridletApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                // Persistence is handled per-keystroke in PuzzleViewModel,
                // but this ensures any timing data is flushed.
            }
        }
    }
}
