import SwiftUI


struct EnvironmentChangeModifier {
    
    let onChange: (EnvironmentValues) -> Void
    
    struct InnerModifier {
        
        let environment: EnvironmentValues
        let onChange: (EnvironmentValues) -> Void
    
        init(environment: EnvironmentValues, onChange: @escaping (EnvironmentValues) -> Void) {
            self.environment = environment
            self.onChange = onChange
        }
    
    }
    
}

extension EnvironmentChangeModifier.InnerModifier : ViewModifier {
    
    func body(content: Content) -> some View {
        content.onChangePolyfill(of: environment.description, initial: true){
            onChange(environment)
        }
    }
    
}

extension EnvironmentChangeModifier : EnvironmentalModifier {
    
    func resolve(in environment: EnvironmentValues) -> some ViewModifier {
        InnerModifier(environment: environment, onChange: onChange)
    }
    
}

public extension View {
    
    /// - Parameter changed: A closure that gets called every time any EnvironmentValue changes.
    /// - Returns: A view that can monitor any `EnvironmentValues` changes.
    nonisolated func onEnvironmentValuesChanged(_ changed: @escaping (EnvironmentValues) -> Void) -> some View {
        modifier(EnvironmentChangeModifier(onChange: changed))
    }
    
}
