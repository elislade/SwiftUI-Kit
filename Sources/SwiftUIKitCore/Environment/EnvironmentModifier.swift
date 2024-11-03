import SwiftUI

public struct EnvironmentModifierWrap <M: ViewModifier>: EnvironmentalModifier {
    
    let modifier: (EnvironmentValues) -> M
    
    public init(_ modifier: @escaping (EnvironmentValues) -> M) {
        self.modifier = modifier
    }
    
    public func resolve(in environment: EnvironmentValues) -> M {
        modifier(environment)
    }
    
}
