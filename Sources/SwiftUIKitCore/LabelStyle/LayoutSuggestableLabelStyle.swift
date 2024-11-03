import SwiftUI


public struct LayoutSuggestableLabelStyle: LabelStyle {
    
    @Environment(\.layoutDirectionSuggestion) private var direction

    public init() { }
    
    @ViewBuilder public func makeBody(configuration: Configuration) -> some View {
        switch direction {
        case .useTopToBottom:
            VStack {
                configuration.icon.imageScale(.large)
                configuration.title.lineLimit(1)
            }
        case .useBottomToTop:
            VStack {
                configuration.title.lineLimit(1)
                configuration.icon.imageScale(.large)
            }
        case .useSystemDefault:
            HStack {
                configuration.icon.imageScale(.large)
                configuration.title.lineLimit(1)
            }
        }
    }
    
}


public extension LabelStyle where Self == LayoutSuggestableLabelStyle {
    
    static var layoutSuggestable: LayoutSuggestableLabelStyle { .init() }
    
}
