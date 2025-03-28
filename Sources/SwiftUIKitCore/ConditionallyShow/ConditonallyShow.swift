import SwiftUI


public extension View {
    
    /// Will conditionally show view depending on current animation Transaction relative to threshold.
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
