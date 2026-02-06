import SwiftUI

public struct InlinePreferenceKeyReader<Key: PreferenceKey, Content: View> where Key.Value : Equatable {
    
    @State private var value: Key.Value
    let content: (Key.Value) -> Content
    
    /// Initializes instance.
    /// - Parameters:
    ///   - key: The` PreferenceKey` to read.
    ///   - content: A view builder that take the PreferenceKey value as an argument.
    public nonisolated init(_ key: Key.Type, @ViewBuilder content: @escaping (Key.Value) -> Content) {
        self.content = content
        self.value = Key.defaultValue
    }
    
}


extension InlinePreferenceKeyReader: View {
    
    public var body: some View {
        content(value)
            .onPreferenceChange(Key.self){ value = $0 }
            .preferenceKeyReset(Key.self)
    }
    
}
