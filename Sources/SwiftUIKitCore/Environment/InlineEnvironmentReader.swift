import SwiftUI

/// Reads Environment value inline without having to use @Environment property wrapper. Usefull for Previews or initializing views wilth just a quick inline wrapper instead of having to create a whole wrapper view just to access an @Environment value.
public struct InlineEnvironmentReader<Value, Content: View>: View {
    
    private let env: Environment<Value>
    private let content: (Value) -> Content
    
    /// Initializes instance
    /// - Parameters:
    ///   - key: The environment key path to be read.
    ///   - content: A ViewBuilder that takes the value of the environment as an argument.
    public init(
        _ key: KeyPath<EnvironmentValues, Value>,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.env = Environment(key)
        self.content = content
    }
    
    public var body: some View {
        content(env.wrappedValue)
    }
    
}
