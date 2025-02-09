import SwiftUI

public struct InlinePreferenceKeyReader<Key: PreferenceKey, Content: View>: View where Key.Value : Equatable & Sendable {
    
    @State private var value: Key.Value?
    let content: (Key.Value?) -> Content
    
    /// Initializes instance.
    /// - Parameters:
    ///   - key: The` PreferenceKey` to read.
    ///   - content: A view builder that take the PreferenceKey value as an argument.
    public init(_ key: Key.Type, @ViewBuilder content: @escaping (Key.Value?) -> Content) {
        self.content = content
        self.value = nil
    }
    
    public var body: some View {
        content(value)
            .onPreferenceChange(Key.self){ value in
                _value.wrappedValue = value
            }
    }
    
}
