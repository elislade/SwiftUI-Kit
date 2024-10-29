import SwiftUI

public struct ViewThatFitsLabelStyle: LabelStyle {
    
    let prefersTitle: Bool
    
    public init(prefersTitle: Bool = false) {
        self.prefersTitle = prefersTitle
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            ViewThatFits{
                Label(configuration)
                    //FIXME: .labelStyle(.layoutSuggestable)
                
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
    
    static var titleIfFits: ViewThatFitsLabelStyle { .init() }
    static var iconIfFits: ViewThatFitsLabelStyle { .init(prefersTitle: true) }
    
}
