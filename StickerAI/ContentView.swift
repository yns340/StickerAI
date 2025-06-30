import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GenerateView()
                .tabItem {
                    Image(systemName: "plus.square")
                    Text("Generate")
                }

            LibraryView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("Library")
                    
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}


#Preview {
    ContentView()
}
