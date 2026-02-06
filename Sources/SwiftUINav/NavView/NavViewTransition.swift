import SwiftUI
import SwiftUIKitCore


public protocol TransitionModifier: ViewModifier {
    
    /// Initialize with amount
    /// - Parameter pushAmount: The amount for the modifier to push. 0 is equivalent to no push and 1 is equivalent to full push.
    /// - Note: This value may not be clamped and could go past 1.
    init(pushAmount: Double)
    
}

public struct EmptyTransition: TransitionModifier {
    
    public init(pushAmount: Double) {}
    
    public func body(content: Content) -> some View {
        content
    }
    
}

public struct DefaultNavTransitionModifier: TransitionModifier {

    @Environment(\.reduceMotion) private var reduceMotion: Bool
    
    let pushAmount: Double
    
    public nonisolated init(pushAmount: Double) {
        self.pushAmount = pushAmount
    }
    
    public func body(content: Content) -> some View {
        let scale: Double = (1 - (pushAmount * 0.1))
        return content
            .mask {
                ContainerRelativeShape()
                    .ignoresSafeArea()
            }
            .scaleIgnoredByLayout(uniform: scale, anchor: .leading)
            .overlay {
                Color.black
                    .opacity(pushAmount / 3)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
    }
    
}
