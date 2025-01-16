import SwiftUI


public extension View {
    
    func callAtAnimationThresholdChange(active: Bool, action: @escaping () -> Void) -> some View {
        modifier(CallAtAnimationThresholdChangeModifier(
            active: active,
            threshold: 0.5,
            action: action
        ))
    }
    
}


struct CallAtAnimationThresholdChangeModifier: ViewModifier & Animatable {
    
    @State private var changed: Bool
    
    let active: Bool
    let threshold: Double
    let action: () -> Void
    
    init(active: Bool, threshold: Double, action: @escaping () -> Void) {
        self._changed = .init(initialValue: active)
        self.active = active
        self.threshold = threshold
        self.action = action
    }
    
    public nonisolated var animatableData: Double {
        get { active ? 1 : 0 }
        set {
            _changed.wrappedValue = newValue > threshold
        }
    }
    
    func body(content: Content) -> some View {
        content
            .onChangePolyfill(of: changed, action)
    }
    
}
