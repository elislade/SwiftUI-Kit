import SwiftUI
import SwiftUIKitCore

struct MenuLabelStyle: LabelStyle {

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            configuration.title
            Spacer(minLength: 10)
            configuration.icon
        }
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
