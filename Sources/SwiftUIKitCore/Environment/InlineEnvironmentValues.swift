import SwiftUI


struct EnvironmentReaderModifier<Reader: View> {
    
    let view: (EnvironmentValues) -> Reader
    
    struct InnerModifier {
        
        let values: EnvironmentValues
        let view: (EnvironmentValues) -> Reader
        
    }
    
}


extension EnvironmentReaderModifier.InnerModifier : ViewModifier {
    
    func body(content: Content) -> some View {
        view(values)
    }
    
}


extension EnvironmentReaderModifier: EnvironmentalModifier {
    
    func resolve(in environment: EnvironmentValues) -> some ViewModifier {
        InnerModifier(values: environment, view: view)
    }
    
}


/// A view that can read **all** EnvironmentValues inline.
public struct InlineEnvironmentValues<Content: View> {

    private let content: (EnvironmentValues) -> Content
    
    /// Initializes view.
    /// - Parameter content: A ViewBuilder of the content that takes EnvironmentValues as an argument.
    public nonisolated init(
        @ViewBuilder content: @escaping (EnvironmentValues) -> Content
    ) {
        self.content = content
    }
     
}


extension InlineEnvironmentValues : View {
    
    public var body: some View {
        Color.clear.modifier(EnvironmentReaderModifier(view: content))
    }
    
}
