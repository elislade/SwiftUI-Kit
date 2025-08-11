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
            .offset(x: reduceMotion ? 0 : pushAmount * -120)
            .overlay {
                Color.black
                    .opacity(depth < 3 ? pushAmount / 2 : 0)
                    .ignoresSafeArea()
            }
    }
    
}
