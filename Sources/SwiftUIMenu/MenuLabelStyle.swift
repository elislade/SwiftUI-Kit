import SwiftUI
import SwiftUIKitCore

struct MenuLabelStyle: LabelStyle {

    @Environment(\.interactionGranularity) private var granularity
    @Environment(\.menuStyle) private var style
    
    private var iconSize: CGFloat {
        35 - (10 * granularity)
    }
    
    private var spacing: CGFloat {
        15 - (10 * granularity)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: style == .regular ? spacing : 0) {
            if style == .regular {
                configuration.icon
                    .frame(width: iconSize, height: iconSize)
            }
            
            configuration.title
                .frame(maxWidth: .infinity, alignment: .leading)
            
            //Spacer(minLength: style == .regular ? 0 : 10)
            
            if style == .compact {
                configuration.icon
            }
        }
        //.frame(minHeight: iconSize)
        //.fixedSize(horizontal: true, vertical: false)
        //.equalInsetItem()
    }
    
}


struct MenuLabeledContentStyle: LabeledContentStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            configuration.label
            Spacer(minLength: 10)
            configuration.content
        }
        .equalInsetItem()
    }
    
}

extension View {
    
    @ViewBuilder func menuLabeledStyle() -> some View {
        labeledContentStyle(MenuLabeledContentStyle())
    }
    
}
