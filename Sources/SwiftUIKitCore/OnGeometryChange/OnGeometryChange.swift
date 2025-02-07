import SwiftUI


public extension View {
    
    func onGeometryChangePolyfill<T: Equatable>(
        for type: T.Type = T.self,
        of transform: @escaping (GeometryProxy) -> T,
        action: @escaping (T) -> Void
    ) -> some View {
        modifier(OnGeometryChangeModifier(transform: transform, didChange: action))
    }
    
    func onGeometryChangePolyfill<T: Equatable>(
        for type: T.Type = T.self,
        of transform: @escaping (GeometryProxy) -> T,
        action: @escaping (_ oldValue: T, _ newValue: T) -> Void
    ) -> some View {
        modifier(OnGeometryChangeOldNewModifier(transform: transform, didChange: action))
    }
    
    func disableOnGeometryChanges(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.onGeometryChangesEnabled){ enabled in
            if disabled {
                enabled = false
            }
        }
    }
    
}


public extension EnvironmentValues {
    
    @Entry var onGeometryChangesEnabled: Bool = true
    
}
