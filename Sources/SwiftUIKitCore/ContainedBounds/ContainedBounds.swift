import SwiftUI


public extension View {
    
    /// Sets bounds for calculating child bounds containment.
    /// - Parameter id: Hashable value to identify this context.
    /// - Returns: A modified view.
    func containedBoundsContext<V: Hashable>(_ id: V) -> some View {
        modifier(ContainedBoundsContext(id: id))
    }
    
    
    /// Use to tell if a view has entered or exited the bounds of a specific `ContainedBoundsContext`.
    /// - Parameters:
    ///   - context: A hashable value identifying what context to use.
    ///   - action: A closure that passes the `ContainedBoundsState` into.
    /// - Returns: A modified view.
    func didChangeContainedBounds<V: Hashable>(in context: V, action: @escaping (ContainedBoundsState) -> Void) -> some View {
        modifier(DidChangeContainedBounds(context: context, action: action))
    }
    
}
