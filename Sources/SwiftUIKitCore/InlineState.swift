import SwiftUI


/// Persists state inline without have to write a view using the `State` property wrapper.
public struct InlineState<Value, Content: View>: View {
    
    private let state: State<Value>
    private let content: (Value) -> Content
    
    /// Initializes inline state
    /// - Parameters:
    ///   - initialValue: The state value that should persist for the identity or existance of the content view.
    ///   - content: A view builder that takes the state as an input and returns a view.
    public init(_ initialValue: Value, @ViewBuilder content: @escaping (Value) -> Content) {
        self.state = .init(initialValue: initialValue)
        self.content = content
    }
    
    public var body: some View {
        content(state.wrappedValue)
    }
    
}


fileprivate struct InlineStateExample: View {
    
    @State private var changeIdentity = 0
    
    var body: some View {
        InlineState(UUID()){ id in
            ZStack {
                Color.random.ignoresSafeArea()
                Text(id.uuidString)
                    .foregroundStyle(Color.white)
                    .blendMode(.exclusion)
            }
            .id(changeIdentity)
            .onTapGesture {
                changeIdentity = .random(in: 0...40)
            }
        }
    }
}


#Preview {
    InlineStateExample()
}
