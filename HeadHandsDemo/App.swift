import SwiftUI

@main
struct HeadHandsDemo: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        
        ImmersiveSpace(id: "immersiveSpace") {
            🌐RealityView()
        }
//        ImmersiveSpace(id)
    }
    
    init() {
        🧑HeadTrackingComponent.registerComponent()
        🧑HeadTrackingSystem.registerSystem()
    }
}
