import SwiftUI

extension View {
    
    public func onPanGesture(
        minNumberOfInputs: Int = 1,
        maxNumberOfInputs: Int = 2,
        perform action: @escaping (PanGestureState) -> Void
    ) -> some View {
        #if canImport(UIKit)
        overlay{
            PanGestureRepresentation(
                minimumNumberOfTouches: minNumberOfInputs,
                maximumNumberOfTouches: maxNumberOfInputs,
                update: action
            )
        }
        #else
        self
        #endif
    }
    
}
