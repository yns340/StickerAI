import SwiftUI
import SwiftData

@main
struct StickerAIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [StickerImage.self]) // 🎯 Bu satır önemli!
    }
}

