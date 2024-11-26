import SwiftUI


public extension View {
    
    /// A gesture that is not directly inputed on the users screen. Eg. trackpad or mouse scroll.
    
    @ViewBuilder func indirectGesture<Gesture: IndirectGesture>(_ gesture: Gesture) -> some View {
        if let gesture = gesture as? IndirectScrollGesture {
            modifier(IndirectScrollModifier(gesture: gesture))
        } else {
            self
        }
    }
    
}
