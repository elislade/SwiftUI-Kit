import SwiftUI

/// A view that can read a **single** environment value inline.
public struct InlineEnvironmentValue<Value, Content: View> {
    
    private let env: Environment<Value>
    private let content: @MainActor (Value) -> Content
    
    /// Initializes instance
    /// - Parameters:
    ///   - key: The environment key path to be read.
    ///   - content: A ViewBuilder that takes the value of the environment as an argument.
    public nonisolated init(
        _ key: KeyPath<EnvironmentValues, Value>,
        @ViewBuilder content: @escaping @MainActor (Value) -> Content
    ) {
        self.env = Environment(key)
        self.content = content
    }
    
}

extension InlineEnvironmentValue: View {
    
    public var body: some View {
        content(env.wrappedValue)
    }
    
}
