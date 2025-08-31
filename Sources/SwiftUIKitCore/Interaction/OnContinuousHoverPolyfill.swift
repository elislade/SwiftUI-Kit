import SwiftUI


public extension View {
    
    nonisolated func onContinuousHoverPolyfill(
        space: CoordinateSpace = .local,
        perform action: @escaping (HoverPhase) -> Void
    ) -> some View {
        modifier(OnContinuousHoverPolyfill(
            coordinateSpace: space,
            action: action
        ))
    }
    
}


struct OnContinuousHoverPolyfill {
    
    @State private var rects: Conversion = .init(.zero, .zero)
    @State private var phase: HoverPhase = .ended
    
    let coordinateSpace: CoordinateSpace
    let action: (HoverPhase) -> Void
  
}

extension OnContinuousHoverPolyfill: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .onGeometryChangePolyfill(of: {
                Conversion(
                    $0.frame(in: .global),
                    $0.frame(in: coordinateSpace)
                )
            }){ rects = $0 }
            .onWindowHover{ evt in
                let point = evt.location
                if coordinateSpace.isLocal {
                    if rects.source.contains(point) {
                        phase = .active(point.translate(by: -rects.source.origin))
                    } else {
                        phase = .ended
                    }
                }
                else if coordinateSpace.isGlobal {
                    if rects.source.contains(point) {
                        phase = .active(point)
                    } else {
                        phase = .ended
                    }
                }
                else {
                    if rects.source.contains(point) {
                        phase = .active(point.translate(by: rects.offset))
                    } else {
                        phase = .ended
                    }
                }
            }
            .onChangePolyfill(of: phase){
                action(phase)
            }
    }
    
}

struct Conversion: Equatable {
    let source: CGRect
    let destination: CGRect
    
    init(_ source: CGRect, _ destination: CGRect) {
        self.source = source
        self.destination = destination
    }
    
    var offset: CGPoint {
        destination.origin.translate(by: -source.origin)
    }
    
}

public enum HoverPhase: Equatable, Sendable, BitwiseCopyable {
    
    /// The pointer's location moved to the specified point within the view.
    case active(CGPoint)

    /// The pointer exited the view.
    case ended

    public var location: CGPoint? {
        switch(self) {
        case .active(let location): return location
        case .ended: return nil
        }
    }
    
    public var isActive: Bool {
        location != nil
    }
    
    public static func == (a: HoverPhase, b: HoverPhase) -> Bool {
        a.location == b.location
    }
    
}
