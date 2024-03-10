import RealityKit
import ARKit
import SwiftUI

// Spawns the balls
enum 🧩Entity {
    static func majorBalls(numBalls: Int) -> [Entity] {
        let vals = (0..<numBalls).map { _ in Self.genericBall(color: UIColor(red: 0, green: 0.87109375, blue: 0.98823529, alpha: 1.0)) }
        return vals
    }

    static func minorBalls(numBalls: Int) -> [Entity] {
        // should be green
        let vals = (0..<numBalls).map { _ in Self.genericBall(color: UIColor(red: 0, green: 0.98823529, blue: 0.2, alpha: 1.0)) }
        return vals
    }
}

// Spawns each ball
private extension 🧩Entity {
    private static func genericBall(color: UIColor) -> Entity {
        let value = Entity()
        let ball = ModelComponent(mesh: .generateSphere(radius: 0.005), materials: [SimpleMaterial(color: color, isMetallic: false)])
        value.components.set([ball,
                              OpacityComponent(opacity:0.6),
                              CollisionComponent(shapes: [.generateSphere(radius:0.005)])])
        return value
    }
}
