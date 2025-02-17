import SwiftUI

struct ConditonallyShowModifier: ViewModifier, Animatable {
    
    private var isShown: Bool
    private let threshold: Double
    
    nonisolated init(isShown: Bool, threshold: Double = 0.5) {
        self.isShown = isShown
        self.threshold = threshold
    }
    
    nonisolated var animatableData: Double {
        get { isShown ? 1 : 0 }
        set { isShown = newValue > threshold }
    }
    
    func body(content: Content) -> some View {
        if isShown {
            content
        }
    }
    
}
