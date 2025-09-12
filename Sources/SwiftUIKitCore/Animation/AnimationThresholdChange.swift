import SwiftUI


public extension View {
    
    nonisolated func onAnimationThresholdChange(_ threshold: Double = 0.5, active: Bool, perform action: @escaping () -> Void) -> some View {
        modifier(AnimationThresholdChangeViewModifier(
            active: active,
            threshold: threshold,
            action: action
        ))
    }
    
    nonisolated func onAnimationComplete(of flag: Bool, perform action: @escaping () -> Void, else elseAction: @escaping () -> Void = {}) -> some View {
        background{
            if !flag {
                Color.clear.onDisappear(perform: action)
            } else {
                Color.clear.onDisappear(perform: elseAction)
            }
        }
    }
    
}


struct AnimationThresholdChangeViewModifier: Animatable {
    
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
    
    
    
}

extension AnimationThresholdChangeViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .onChangePolyfill(of: changed, action)
    }
    
}
