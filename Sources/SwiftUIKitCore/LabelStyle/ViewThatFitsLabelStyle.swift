import SwiftUI

public struct ViewThatFitsLabelStyle: LabelStyle {
    
    private let prefersTitle: Bool
    
    public nonisolated init<V: View>(preferring view: KeyPath<Configuration, V>) {
        self.prefersTitle = view == \.title
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        ViewThatFits{
            Label(configuration)
                .labelStyle(.layoutSuggestable)
            
            if prefersTitle {
                Label(configuration)
                    .labelStyle(.titleOnly)
            }
            
            Label(configuration)
                .labelStyle(.iconOnly)
        }
    }
    
}


public extension LabelStyle where Self == ViewThatFitsLabelStyle {
   
    static nonisolated var viewThatFits: ViewThatFitsLabelStyle {
        .init(preferring: \.icon)
    }
    
    static nonisolated func viewThatFits<V: View>(preferring view: KeyPath<LabelStyle.Configuration, V> = \.icon) -> ViewThatFitsLabelStyle {
        .init(preferring: view)
    }
    
}
