import SwiftUI


public struct LayoutSuggestableLabelStyle: LabelStyle {
    
    @Environment(\.layoutDirectionSuggestion) private var direction

    public init() { }
    
    @ViewBuilder public func makeBody(configuration: Configuration) -> some View {
        switch direction {
        case .useTopToBottom:
            VStack {
                configuration.icon
                configuration.title
            }
        case .useBottomToTop:
            VStack {
                configuration.title
                configuration.icon
            }
        case .useSystemDefault:
            HStack {
                configuration.icon
                configuration.title
            }
        }
    }
    
}


public extension LabelStyle where Self == LayoutSuggestableLabelStyle {
    
    static var layoutSuggestable: LayoutSuggestableLabelStyle { .init() }
    
}
