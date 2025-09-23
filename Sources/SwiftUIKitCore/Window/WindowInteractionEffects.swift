import SwiftUI


struct WindowInteractionEffects: ViewModifier {
    
    @Environment(\.reduceMotion) private var reduceMotion: Bool
    
    @State private var rect: CGRect = .zero
    @State private var offset: CGSize = .zero
    @State private var scale: SIMD2<Double> = [1,1]
    @State private var scaleAnchor: UnitPoint = .center
    
    let effects: Set<InteractionEffect>
    
    private func uniform(scale: Double){
        self.scale = [scale, scale]
    }
    
    nonisolated init(_ effects: Set<InteractionEffect> = []) {
        self.effects = effects
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(CGSize(scale), anchor: scaleAnchor)
            .offset(offset)
            .onGeometryChangePolyfill(of: { $0.frame(in: .global) }){ rect = $0 }
            .onWindowDrag { evt in
                guard !reduceMotion, !effects.isEmpty, let location = evt.locations.last else {
                    return
                }
                
                if evt.phase == .ended {
                    self.offset = .zero
                    self.scale = [1,1]
                    return
                }
                
                for effect in effects {
                    switch effect {
                    case .squish:
                        // as an item squishes along an axis, it's scale will shrink along axis of travel and grow on axis perpindicular to travel.
                        let distance = location.distance(to: CGPoint(x: rect.midX, y: rect.midY))
                        let falloff: CGFloat = min(abs(distance) / 300, 1)
                        
                        scale = [
                            1.0 + (falloff * 0.07),
                            1.0 - (falloff * 0.05)
                        ]
                        
                        let distanceX = location.x - rect.origin.x
                        let distanceY = location.y - rect.origin.y
                        
                        scaleAnchor = .init(
                            x: distanceX / rect.width,
                            y: distanceY / rect.height
                        )
                    case .scale(let anchor):
                        let distance = location.distance(from: rect)
                        uniform(scale: 1.0 - (pow(distance, 0.6) / 100))
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
            }
            .disableWindowDrag(effects.isEmpty)
            .animation(.bouncy(extraBounce: 0.13), value: scale)
            .animation(.bouncy, value: offset)
            .animation(.bouncy, value: scaleAnchor)
    }
    
}


public enum InteractionEffect: Hashable, Sendable {
    
    case squish
    case scale(anchor: UnitPoint = .center)
    case parallax(amount: Double = 1)
    
}


public extension View {
    
    nonisolated func windowInteractionEffects(_ effects: Set<InteractionEffect>) -> some View {
        modifier(WindowInteractionEffects(effects))
    }
    
}
