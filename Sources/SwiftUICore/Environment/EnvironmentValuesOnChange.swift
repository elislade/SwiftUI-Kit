import SwiftUI


struct EnvChangeModifier: EnvironmentalModifier {
    
    let onChange: (EnvironmentValues) -> Void
    
    func resolve(in environment: EnvironmentValues) -> some ViewModifier {
        Modifier(environment: environment, onChange: onChange)
    }
    
    struct Modifier: ViewModifier {
        
        let environment: EnvironmentValues
        let onChange: (EnvironmentValues) -> Void
    
        func body(content: Content) -> some View {
            content.onChangePolyfill(of: environment.description, initial: true){
                onChange(environment)
            }
        }
    
    }
}


public extension View {
    
    /// - Parameter changed: A closure that gets called every time any EnvironmentValue changes.
    /// - Returns: A view that can monitor any `EnvironmentValues` changes.
    func onEnvironmentValuesChanged(_ changed: @escaping (EnvironmentValues) -> Void) -> some View {
        modifier(EnvChangeModifier(onChange: changed))
    }
    
}
