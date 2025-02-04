import SwiftUI


struct LongPressWindowInteraction: ViewModifier {
    
    let minimumDuration: TimeInterval
    let maximumDistance: Double
    let trigger: () -> Void
    
    @State private var timer: Timer?
    @State private var shouldTrigger = false
    @State private var rect: CGRect = .zero
    @State private var start: CGPoint = .zero
    @State private var last: CGPoint = .zero
    
    private var withinDistance: Bool {
        start.distance(to: last) <= maximumDistance
    }
    
    func body(content: Content) -> some View {
        content
            .onGeometryChangePolyfill(of: { $0.frame(in: .global) }){ rect = $0 }
            .onChangePolyfill(of: shouldTrigger){
                if shouldTrigger {
                    trigger()
                }
            }
            .onWindowDrag{ evt in
                switch evt.phase {
                case .began:
                    if let point = evt.locations.first, rect.contains(point) {
                        start = point
                        last = point
                        timer = .scheduledTimer(withTimeInterval: minimumDuration, repeats: false){ _ in
                            _shouldTrigger.wrappedValue = true
                        }
                    }
                case .changed:
                    last = evt.locations.first ?? .zero
                    if !withinDistance {
                        timer?.invalidate()
                        shouldTrigger = false
                    }
                case .ended:
                    timer?.invalidate()
                    timer = nil
                    shouldTrigger = false
                }
            }
    }
    
}
