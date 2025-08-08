import SwiftUI


/// Stores a value and passes binded wrapper to content.
public struct InlineBinding<Content: View, Value> {
    
    private let value: State<Value>
    private let content: (Binding<Value>) -> Content

    /// Creates an instance of InlineBinding
    ///
    /// - Parameters:
    ///   - value: The default binding value.
    ///   - content: The view builder of the content that gets the inlined binding value.
    public nonisolated init(_ value: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self.value = State(initialValue: value)
        self.content = content
    }
    
}


extension InlineBinding: View {
    
    public var body: some View { content(value.projectedValue) }
    
}
