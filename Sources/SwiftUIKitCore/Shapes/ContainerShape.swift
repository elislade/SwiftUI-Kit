import SwiftUI


struct PrefersContainerShapeKey: EnvironmentKey {
    
    static var defaultValue: Bool { false }
    
}


public extension EnvironmentValues {
    
    /// A Bool indicating that the environment prefers the use of the container shape. If the suggestion is of use to a view it should use the `ContainerRelativeShape` over any default shape it's using.
    var prefersContainerShape: Bool {
        get { self[PrefersContainerShapeKey.self] }
        set { self[PrefersContainerShapeKey.self] = newValue }
    }
    
}


public extension View {
    
    /// Sets the `containerShape(_:)` and the environment ``prefersContainerShape`` value to `true`. If the view supports this it will use the Shape instead of its default Shape.
    /// - Note: This modifier should be applied directly to the view that should use this suggestion as `ContainerRelativeShape` can have undesired results if its bounds are too far away from the applied view.
    /// - Parameter shape: A shape conforming to `InsettableShape`.
    /// - Returns: A view.
    func useContainerShape<Shape: InsettableShape>(_ shape: Shape) -> some View {
        containerShape(shape)
            .environment(\.prefersContainerShape, true)
    }
    
}
