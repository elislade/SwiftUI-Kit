import SwiftUI

struct ConditonallyShowModifier: ViewModifier, Animatable {
    
    private var isShown: Bool
    private let threshold: Double
    
    init(isShown: Bool, threshold: Double = 0.5) {
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


public extension View {
    
    /// Will conditonally show view depending on current animation Transaction relative to threshold.
    /// If no animation is associated with the current transaction, the visibility will change instantaneously.
    /// 
    /// - Parameters:
    ///   - animatingCondition: A Boolean indicating the views visibility.
    ///   - threshold: A threshold of the current transaction where a 0 threshold is the beginning of the transaction and 1 is the end. Any value above threshold will show view. Defaults to 0.5.
    /// - Returns: A view that will show or hide its self depending on condition and threshold.
    func conditonallyShow(animatingCondition: Bool, threshold: Double = 0.5) -> some View {
        modifier(ConditonallyShowModifier(
            isShown: animatingCondition,
            threshold: threshold
        ))
    }
    
}
