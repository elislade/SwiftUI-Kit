import SwiftUI


struct WindowInteractionEffects: ViewModifier {
    
    @State private var rect: CGRect = .zero
    @State private var offset: CGSize = .zero
    @State private var scale: Double = 1
    @State private var scaleAnchor: UnitPoint = .center
    
    let effects: Set<InteractionEffect>
    
    nonisolated init(_ effects: Set<InteractionEffect> = []) {
        self.effects = effects
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor:  scaleAnchor)
            .offset(offset)
            .onGeometryChangePolyfill(of: { $0.frame(in: .global) }){ rect = $0 }
            .windowInteraction(started: { _ in }){ points in
                guard !effects.isEmpty, let location = points.last else {
                    return
                }
                
                for effect in effects {
                    switch effect {
                    case .scale(let anchor):
                        let distance = location.distance(from: rect)
                        scale = 1.0 - (pow(distance, 0.6) / 100)
                        scaleAnchor = anchor
                    case .parallax(let amount):
                        let x = location.x - rect.midX
                        let y = location.y - rect.midY
                        let falloff: CGFloat = 200
                        let xFalloffFactor = min(abs(x) / falloff, 1)
                        let yFalloffFactor = min(abs(y) / falloff, 1)
                        
                        let xd: CGFloat = x - (x * xFalloffFactor)
                        let yd: CGFloat = y - (y * yFalloffFactor)
                        
                        self.offset = .init(
                            width: (xd / 10) * amount,
                            height: (yd / 10) * amount
                        )
                    }
                }
            } ended: { _ in
                self.offset = .zero
                self.scale = 1
            }
            .disableWindowEvents(effects.isEmpty)
            .animation(.bouncy, value: scale)
            .animation(.bouncy, value: offset)
    }
    
}


public enum InteractionEffect: Hashable, Sendable {
    
    case scale(anchor: UnitPoint = .center)
    case parallax(amount: Double = 1)
    
}


public extension View {
    
    nonisolated func windowInteractionEffects(_ effects: Set<InteractionEffect>) -> some View {
        modifier(WindowInteractionEffects(effects))
    }
    
}
