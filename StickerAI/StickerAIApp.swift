import SwiftUI
import SwiftData

@main
struct StickerAIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [ImageFile.self]) // 🎯 Bu satır önemli!
    }
}

