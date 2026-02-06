import SwiftUI

extension View {
    
#if os(visionOS)
    
    nonisolated public func sensoryFeedbackPolyfill<V: Equatable>(_ feedback: FeedbackType = .selectionChange, value: V) -> Self {
        self
    }
    
#else
    
    @ViewBuilder nonisolated public func sensoryFeedbackPolyfill<V: Equatable>(
        _ feedback: FeedbackType = .selectionChange,
        value: V,
        condition: @escaping (_ oldValue: V, _ newValue: V) -> Bool = { o, n in o != n }
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            sensoryFeedback(.map(type: feedback), trigger: value){ condition($0, $1) }
        } else {
            modifier(SensoryFeedbackModifier(type: feedback, value: value))
        }
    }
    
#endif
    
}
