import SwiftUI


public extension View {
    
    func onAnimationThresholdChange(_ threshold: Double = 0.5, active: Bool, perform action: @escaping () -> Void) -> some View {
        modifier(AnimationThresholdChangeViewModifier(
            active: active,
            threshold: threshold,
            action: action
        ))
    }
    
    func onAnimationComplete(when completeFlag: Bool, perform action: @escaping () -> Void, else elseAction: @escaping () -> Void = {}) -> some View {
        background{
            if !completeFlag {
                Color.clear.onDisappear(perform: action)
            } else {
                Color.clear.onDisappear(perform: elseAction)
            }
        }
    }
    
}


struct AnimationThresholdChangeViewModifier: ViewModifier & Animatable {
    
    private let active: Bool
    private let threshold: Double
    private let action: () -> Void
    private var changed: Bool
    
    init(active: Bool, threshold: Double, action: @escaping () -> Void) {
        self.changed = active
        self.active = active
        self.threshold = threshold
        self.action = action
    }
    
    public nonisolated var animatableData: Double {
        get { active ? 1 : 0 }
        set {
            changed = newValue > threshold
        }
    }
    
    func body(content: Content) -> some View {
        content
            .onChangePolyfill(of: changed, action)
    }
    
}
