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
                //.font(.body[.semibold])
            
            //Spacer(minLength: style == .regular ? 0 : 10)
            
            if style == .compact {
                configuration.icon
            }
        }
        //.fixedSize(horizontal: true, vertical: false)
        .font(.body[.semibold])
        .equalInsetItem()
    }
    
}


@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
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
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            labeledContentStyle(MenuLabeledContentStyle())
        } else {
            self
        }
    }
    
}
