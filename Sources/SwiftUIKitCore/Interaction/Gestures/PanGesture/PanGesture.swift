import SwiftUI

public extension View {
    
    #if canImport(UIKit) && !os(watchOS)
    
    func onPanGesture(
        minNumberOfInputs: Int = 1,
        maxNumberOfInputs: Int = 2,
        perform action: @escaping (PanGestureState) -> Void
    ) -> some View {
        overlay{
            PanGestureRepresentation(
                minimumNumberOfTouches: minNumberOfInputs,
                maximumNumberOfTouches: maxNumberOfInputs,
                update: action
            )
        }
    }
    
    #else
    
    func onPanGesture(
        minNumberOfInputs: Int = 1,
        maxNumberOfInputs: Int = 2,
        perform action: @escaping (PanGestureState) -> Void
    ) -> Self {
        self
    }
    
    #endif
    
}
