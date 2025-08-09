import SwiftUI


public extension AnyTransition {
    
    static func merge(_ collection: AnyTransition...) -> AnyTransition  {
        collection.merged()
    }
    
    static func merge<C: Collection>(_ collection: C) -> AnyTransition where C.Element == AnyTransition {
        collection.merged()
    }
        
    static func moveFade(edge: Edge) -> AnyTransition {
        .move(edge: edge) + .opacity
    }
    
    static func insertion(_ transitions: AnyTransition...) -> AnyTransition {
        .asymmetric(insertion: .merge(transitions), removal: .identity)
    }
    
    static func removal(_ transitions: AnyTransition...) -> AnyTransition {
        .asymmetric(insertion: .identity, removal: .merge(transitions))
    }

    static func moveOffset(edge: Edge = .leading) -> AnyTransition {
        .move(edge: edge) + .offset(x: edge == .leading ? -50 : 50)
    }
    
    static func zIndex(_ index: Double = 2) -> AnyTransition {
        .modifier(
            active: ZIndexModifier(index: index),
            identity: ZIndexModifier(index: index)
        )
    }
    
    static func clipRoundedRectangle(_ shape: RoundedRectangle) -> AnyTransition {
        .modifier(
            active: ClipShapeModifier(shape: shape),
            identity: ClipShapeModifier(shape: RoundedRectangle(cornerRadius: 0))
        )
    }
    
}


public extension View {
    
    func transitions(_ collection: AnyTransition...) -> some View  {
        transition(.merge(collection))
    }
    
    func transitions<C: Collection>(_ collection: C) -> some View where C.Element == AnyTransition {
        transition(.merge(collection))
    }
    
}


public extension Collection where Element == AnyTransition {
    
    func merged() -> AnyTransition {
        guard !isEmpty else { return .identity }
        
        return reduce(into: AnyTransition.identity){ a, b in
            a = a.combined(with: b)
        }
    }
    
}


public func +(lhs: AnyTransition, rhs: AnyTransition) -> AnyTransition {
    lhs.combined(with: rhs)
}


@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@MainActor public func +<L: Transition, R: Transition>(lhs: L, rhs: R) -> some Transition {
    lhs.combined(with: rhs)
}
