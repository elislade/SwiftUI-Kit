import SwiftUI


struct WindowCoordinatedEffects: ViewModifier {
    
    @Environment(\.lastWindowCoordinatedInteractionLocation) private var lastCoordinatedInteractionLocation
    @State private var rect: CGRect = .zero
    
    var effects: Set<CoordinatedInteractionEffect> = []
    
    private var effectsOffset: CGSize {
        guard !effects.isEmpty, let location = lastCoordinatedInteractionLocation else {
            return .zero
        }
        
        for effect in effects {
            if case .parallax(let amount) = effect {
                let x = location.x - rect.midX
                let y = location.y - rect.midY
                let falloff: CGFloat = 200
                let xFalloffFactor = min(abs(x) / falloff, 1)
                let yFalloffFactor = min(abs(y) / falloff, 1)
                
                let xd: CGFloat = x - (x * xFalloffFactor)
                let yd: CGFloat = y - (y * yFalloffFactor)
                
                return .init(
                    width: (xd / 10) * amount,
                    height: (yd / 10) * amount
                )
            }
        }
        
        return .zero
    }
    
    
    private var effectsScale: (CGFloat, UnitPoint) {
        guard !effects.isEmpty, let location = lastCoordinatedInteractionLocation else {
            return (1, .center)
        }
        
        for effect in effects {
            if case .scale(let anchor) = effect {
                let distance = location.distance(from: rect)
                return (1.0 - (pow(distance, 0.6) / 100), anchor)
            }
            
        }

        return (1, .center)
    }
    
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(effectsScale.0, anchor: effectsScale.1)
            .offset(effectsOffset)
            .boundsReader(readingToRect: $rect)
            .wantsWindowCoordinatedInteraction(!effects.isEmpty)
            .animation(.bouncy, value: effectsScale.0)
            .animation(.bouncy, value: effectsOffset)
    }
    
}


public enum CoordinatedInteractionEffect: Hashable {
    
    case scale(anchor: UnitPoint = .center)
    case parallax(amount: Double = 1)
    
}


public extension View {
    
    func coordinatedTouchesEffects(_ effects: Set<CoordinatedInteractionEffect>) -> some View {
        modifier(WindowCoordinatedEffects(effects: effects))
    }
    
}


struct CoordinatedEventsModifier: ViewModifier {
    
    @State private var coordinated: [InteractionEvent] = []
    @State private var wantsCoordination = false
    
    func body(content: Content) -> some View {
        content
            .windowInteractionChanged(enabled: wantsCoordination){ coordinated = $0.map{ .init(location: $0) } }
            .environment(\.windowCoordinatedInteractionEvents, wantsCoordination ? coordinated : [])
            .onPreferenceChange(WantsWindowCoordinatedInteractionKey.self){
                wantsCoordination = $0
            }
            .transformPreference(WantsWindowCoordinatedInteractionKey.self) { value in
                // stops any true values propagating to possible parent coordinators above this one.
                value = false
            }
    }
    
}


public extension View {
    
    func coordinatedWindowEvents() -> some View {
        modifier(CoordinatedEventsModifier())
    }
    
}
