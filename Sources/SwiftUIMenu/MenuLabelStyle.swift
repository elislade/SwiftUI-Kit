import SwiftUI
import SwiftUICore

struct MenuLabelStyle: LabelStyle {

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            configuration.title
            Spacer(minLength: 10)
            configuration.icon
        }
        .applyMenuItemInsets()
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
        .applyMenuItemInsets()
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


struct MenuToggleStyle: ToggleStyle {
    
    @Environment(\.menuItemInsets) private var menuItemInsets
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.$isOn.wrappedValue.toggle() }){
            HStack(spacing: 0) {
                Image(systemName: "checkmark")
                    .resizable()
                    .scaledToFit()
                    .opacity(configuration.isOn ? 1 : 0)
                    .frame(width: 12)
                    .frame(width: menuItemInsets.leading)
                    .font(.body.weight(.semibold))
                
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .applyMenuItemInsets([.vertical, .trailing])
            }
        }
        .preferMenuItemInsets(.leading, .menuLeadingSpacerSize)
    }
    
}

