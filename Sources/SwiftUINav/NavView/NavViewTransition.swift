import SwiftUI
import SwiftUIKitCore


public protocol TransitionModifier: ViewModifier {
    
    /// Initialize with amount
    /// - Parameter pushAmount: The amount for the modifier to push. 0 is equivalent to no push and 1 is equivalent to full push.
    /// - Note: This value may not be clamped and could go past 1.
    init(pushAmount: Double)
    
}


public struct DefaultNavTransitionModifier: TransitionModifier {

    @Environment(\.presentationDepth) private var depth: Int
    @Environment(\.reduceMotion) private var reduceMotion: Bool
    
    let pushAmount: Double
    
    public nonisolated init(pushAmount: Double) {
        self.pushAmount = pushAmount
    }
    
    public func body(content: Content) -> some View {
        content
            .opacity(depth < 2 ? 1 - (pushAmount * 0.7) : 0)
            .scaleEffect(1 - (pushAmount * 0.2), anchor: .leading)
            .overlay {
                Color.black
                    .opacity(depth < 2 ? pushAmount / 4 : 0)
                    .allowsHitTesting(false)
            }
    }
    
}
