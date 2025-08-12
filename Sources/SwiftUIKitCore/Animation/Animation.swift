import SwiftUI

public extension Animation {
    
    static let fastSpring = Animation.spring().speed(1.5)
    
    static let fastSpringInteractive: Animation = .interactiveSpring(
        response: 0.23,
        dampingFraction: 0.83
    )
    
    static let fastSpringInterpolating: Animation = .interpolatingSpring(
        mass: 0.2,
        stiffness: 90,
        damping: 120,
        initialVelocity: 0.5
    )
    
    static func interpolating(velocity: CGFloat) -> Animation {
        .interpolatingSpring(
            mass: 0.2,
            stiffness: 90,
            damping: 120,
            initialVelocity: velocity
        )
    }
    
}


public extension View {
    
    nonisolated func delayAnimation(_ delay: Double) -> some View {
        transaction{
            $0.animation = $0.animation?.delay(delay)
        }
    }
    
    nonisolated func disableAnimations(_ disabled: Bool = true) -> some View {
        transaction{
            if disabled {
                $0.disablesAnimations = true
                $0.animation = nil
            }
        }
    }
    
}
