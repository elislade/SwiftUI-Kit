import SwiftUI

public struct ViewThatFitsLabelStyle: LabelStyle {
    
    private let prefersTitle: Bool
    
    public nonisolated init<V: View>(preferring view: KeyPath<Configuration, V>) {
        self.prefersTitle = view == \.title
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
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
        } else {
            Label(configuration)
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
