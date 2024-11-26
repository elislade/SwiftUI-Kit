import SwiftUI


struct SimultaneousLongPressModifier: ViewModifier {
    
    var minimumDuration: TimeInterval = 0.3
    var maximumDistance: Double = 10
    var trigger: () -> Void
    
    func body(content: Content) -> some View {
        if #available(iOS 18, macOS 15, *){
            content.gesture(
                LongPressGesture(minimumDuration: minimumDuration, maximumDistance: maximumDistance)
                    .onEnded{ _ in
                        trigger()
                    }
            )
        } else {
            content.overlay {
                #if canImport(UIKit)
                SimultaneousLongPressRepresentation(
                    minimumDuration: minimumDuration,
                    maximumDistance: maximumDistance,
                    trigger: trigger
                )
                #endif
            }
        }
    }
    
}
