import SwiftUI


public struct EnvironmentModifierWrap <Modifier: ViewModifier> {
    
    private let closure: (EnvironmentValues) -> Modifier
    
    public nonisolated init(_ closure: @escaping (EnvironmentValues) -> Modifier) {
        self.closure = closure
    }
    
}

extension EnvironmentModifierWrap: EnvironmentalModifier {
    
    public func resolve(in environment: EnvironmentValues) -> Modifier {
        closure(environment)
    }
    
}
