import SwiftUI

struct EnvReaderModifier<Reader: View>: @preconcurrency EnvironmentalModifier {
    
    let view: (EnvironmentValues) -> Reader
    
    func resolve(in environment: EnvironmentValues) -> some ViewModifier {
        Modifier(values: environment, view: view)
    }
    
    struct Modifier: ViewModifier {
        
        let values: EnvironmentValues
        let view: (EnvironmentValues) -> Reader
        
        func body(content: Content) -> some View {
            view(values)
        }
        
    }
    
}


/// A View that can read **all** EnvironmentValues inline.
public struct InlineEnvironmentValuesReader<Content: View> {

    private let content: (EnvironmentValues) -> Content
    
    /// Initializes view.
    /// - Parameter content: A ViewBuilder of the content that takes EnvironmentValues as en argument.
    public nonisolated init(
        @ViewBuilder content: @escaping (EnvironmentValues) -> Content
    ) {
        self.content = content
    }
     
}


extension InlineEnvironmentValuesReader : View {
    
    public var body: some View {
        Color.clear.modifier(EnvReaderModifier(view: content))
    }
    
}
