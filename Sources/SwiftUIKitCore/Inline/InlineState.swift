import SwiftUI


/// Persists state inline without have to write a view using the `State` property wrapper.
public struct InlineState<Value, Content: View> {
    
    private let state: State<Value>
    private let content: (Value) -> Content
    
    /// Initializes inline state
    /// - Parameters:
    ///   - initialValue: The state value that should persist for the identity or existance of the content view.
    ///   - content: A view builder that takes the state as an input and returns a view.
    public nonisolated init(_ initialValue: Value, @ViewBuilder content: @escaping (Value) -> Content) {
        self.state = .init(initialValue: initialValue)
        self.content = content
    }
    
}


extension InlineState: View {
    
    public var body: some View {
        content(state.wrappedValue)
    }
    
}
