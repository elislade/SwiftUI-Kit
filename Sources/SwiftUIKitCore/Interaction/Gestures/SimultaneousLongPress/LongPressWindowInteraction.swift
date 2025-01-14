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
            .windowDrag{ p in
                if let point = p.first, rect.contains(point) {
                    start = point
                    last = point
                    timer = .scheduledTimer(withTimeInterval: minimumDuration, repeats: false){ _ in
                        _shouldTrigger.wrappedValue = true
                    }
                }
            } changed: {
                last = $0.first ?? .zero
                if !withinDistance {
                    timer?.invalidate()
                    shouldTrigger = false
                }
            } ended: { p in
                timer?.invalidate()
                timer = nil
                shouldTrigger = false
            }
    }
    
}
