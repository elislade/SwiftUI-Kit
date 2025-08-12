import SwiftUI

public extension View {
    
#if os(visionOS)
    
    nonisolated func sensoryFeedbackPolyfill<V: Equatable>(_ feedback: FeedbackType = .selectionChange, value: V) -> Self {
        self
    }
    
#else
    
    @ViewBuilder nonisolated func sensoryFeedbackPolyfill<V: Equatable>(_ feedback: FeedbackType = .selectionChange, value: V) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            sensoryFeedback(.map(type: feedback), trigger: value)
        } else {
            modifier(SensoryFeedbackModifier(type: feedback, value: value))
        }
    }
    
#endif
    
}
