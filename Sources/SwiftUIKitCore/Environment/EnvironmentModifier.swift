import SwiftUI

public struct EnvironmentModifierWrap <Modifier: ViewModifier>: @preconcurrency EnvironmentalModifier {
    
    private let closure: (EnvironmentValues) -> Modifier
    
    public init(_ closure: @escaping (EnvironmentValues) -> Modifier) {
        self.closure = closure
    }
    
    public func resolve(in environment: EnvironmentValues) -> Modifier {
        closure(environment)
    }
    
}
