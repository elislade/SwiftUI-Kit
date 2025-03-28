import SwiftUI


struct SimultaneousLongPressModifier: ViewModifier {
    
    var minimumDuration: TimeInterval = 0.3
    var maximumDistance: Double = 10
    var trigger: () -> Void
    
    func body(content: Content) -> some View {
        if #available(iOS 18, macOS 15, tvOS 18, *){
            #if os(tvOS)
            content.gesture(
                LongPressGesture()
                    .onEnded{ _ in trigger() }
            )
            #else
            content.gesture(
                LongPressGesture(minimumDuration: minimumDuration, maximumDistance: maximumDistance)
                    .onEnded{ _ in trigger() }
            )
            #endif
        } else {
            content
                .overlay{
                    #if os(iOS)
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
