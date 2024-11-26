import SwiftUI


public extension View {
    
    func simultaneousLongPress(
        minimumDuration: TimeInterval = 0.3,
        maximumDistance: Double = 10,
        _ trigger: @escaping () -> Void
    ) -> some View {
        modifier(SimultaneousLongPressModifier(
            minimumDuration: minimumDuration,
            maximumDistance: maximumDistance,
            trigger: trigger
        ))
    }
    
}
