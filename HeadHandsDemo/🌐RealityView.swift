import SwiftUI
import RealityKit
import ARKit

struct 🌐RealityView: View {
    @StateObject var model: 🥽AppModel = .init()
    
    @State var sceneContent: Entity?
    @State var contentHolder: (any RealityViewContentProtocol)?
    
    var body: some View {
        RealityView { content in
            content.add(self.model.rootEntity)
            self.model.setUpChildEntities()
            contentHolder = content;
            
            // Load in head model
            if let head = try? await Entity(named: "andyhead3d2") {
                head.setPosition(SIMD3(x:0, y:2.5, z:-1), relativeTo: nil)
                head.components.set(🧑HeadTrackingComponent()) // This makes it track you
                
                self.model.rootEntity.addChild(head)
                content.add(head)
                sceneContent = head
            }
            
        }  update: { (content) in
            // call a function in AppModel that recognizes custom hand gestures
            let customGestures = self.model.detectCustomTaps()
        }
        .background {
            🛠️MenuTop()
                .environmentObject(self.model)
        }
        .task { self.model.run() }
        .task { self.model.observeAuthorizationStatus() }
        .upperLimbVisibility(.hidden) // Hide hands so we can display dots over the joints
    }
    
    // Adds a copy of the author's head model at the given position
    func addFace(pos: SIMD3<Float>){
        let headclone = (sceneContent?.clone(recursive: true))!
        headclone.setPosition(pos, relativeTo: nil)
        contentHolder?.add(headclone)
    }
}
