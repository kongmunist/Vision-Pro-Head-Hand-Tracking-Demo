import SwiftUI
import RealityKit
import ARKit

@MainActor
class 🥽AppModel: ObservableObject {
    @Published private(set) var authorizationStatus: ARKitSession.AuthorizationStatus?
    @Published var presentPanel: 🛠️Panel? = nil
    @Published var selectedLeft: Bool = false
    @Published var selectedRight: Bool = false
    
    // Public var that maintains each hand's last handAnchor + joints
    @Published var latestHandTracking: HandsUpdates = .init(left: nil, right: nil)
    struct HandsUpdates {
        var left: HandAnchor?
        var right: HandAnchor?
    }
    
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()
    
    let rootEntity = Entity()
    
    // Take only 3 joints per finger + wrist (except thumb has two)
        // Labeled in blue
    let majorHandJoints: [HandSkeleton.JointName] = [
        .thumbIntermediateBase, .thumbTip,
        .indexFingerIntermediateBase, .indexFingerKnuckle, .indexFingerTip,
        .middleFingerIntermediateBase, .middleFingerKnuckle, .middleFingerTip,
        .ringFingerIntermediateBase, .ringFingerKnuckle, .ringFingerTip,
        .littleFingerIntermediateBase, .littleFingerKnuckle, .littleFingerTip,
        .wrist
    ]
    
    // Labeled in green
    let minorHandJoints: [HandSkeleton.JointName] = [
        .thumbKnuckle, .thumbIntermediateTip,
        .indexFingerMetacarpal, .indexFingerIntermediateTip,
        .middleFingerMetacarpal, .middleFingerIntermediateTip,
        .ringFingerMetacarpal, .ringFingerIntermediateTip,
        .littleFingerMetacarpal, .littleFingerIntermediateTip,
        .forearmArm, .forearmWrist
    ]

    // only one duplicate, the thumbIntermediateBase 
    
    let majorBalls: [Entity] = 🧩Entity.majorBalls(numBalls: 30);
    let minorBalls: [Entity] = 🧩Entity.minorBalls(numBalls: 24);

    
    func setUpChildEntities() {
        self.majorBalls.forEach { self.rootEntity.addChild($0) }
        self.minorBalls.forEach { self.rootEntity.addChild($0) }
    }
    
    // Check that we have ARKit authorization for hand and head tracking
    func observeAuthorizationStatus() {
        Task {
            self.authorizationStatus = await self.session.queryAuthorization(for: [.handTracking])[.handTracking]
            
            for await update in self.session.events {
                if case .authorizationChanged(let type, let status) = update {
                    if type == .handTracking { self.authorizationStatus = status }
                } else {
                    print("Another session event \(update).")
                }
            }
        }
    }
    
    func run() {
        Task { @MainActor in
            do {
                try await self.session.run([self.handTracking])
                await self.processHandUpdates()
            } catch {
                print(error)
            }
        }
    }

    // Add function that detects custom tap gestures
    func detectCustomTaps() -> Int? {
        // Make sure both hands are tracked rn
        guard let leftHandAnchor = latestHandTracking.left,
              let rightHandAnchor = latestHandTracking.right,
              leftHandAnchor.isTracked, rightHandAnchor.isTracked else {
            return nil
        }
        
//        print("ran detectCustomTaps")
        
        return 0
    }
    
    public var leftPosition: SIMD3<Float> {
        self.majorBalls[5].position
    }
    
    public var rightPosition: SIMD3<Float> {
        self.majorBalls[21].position
    }
}

private extension 🥽AppModel {
    private func processHandUpdates() async {
        for await update in self.handTracking.anchorUpdates {
            let handAnchor = update.anchor
            guard handAnchor.isTracked else { continue }
            
            // Update published hand pose
            if handAnchor.chirality == .left {
                latestHandTracking.left = handAnchor
            } else if handAnchor.chirality == .right { // Update right hand info.
                latestHandTracking.right = handAnchor
            }

            // Update ball positions for each joint. If it's the left hand, start at 0, if it's the right hand, start at 16.
            var start = handAnchor.chirality == .left ? 0 : majorHandJoints.count
            for i in 0..<(majorHandJoints.count) {
                let pos = handAnchor.handSkeleton?.joint(majorHandJoints[i])
                let worldPos = handAnchor.originFromAnchorTransform * pos!.anchorFromJointTransform
                self.majorBalls[i + start].setTransformMatrix(worldPos, relativeTo:nil)
            }
            // Minor joints now
            start = handAnchor.chirality == .left ? 0 : minorHandJoints.count
            for i in 0..<(minorHandJoints.count) {
                let pos = handAnchor.handSkeleton?.joint(minorHandJoints[i])
                let worldPos = handAnchor.originFromAnchorTransform * pos!.anchorFromJointTransform
                self.minorBalls[i + start].setTransformMatrix(worldPos, relativeTo:nil)
            }
        }
    }
}

