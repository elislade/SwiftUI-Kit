import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


public struct MenuContainer<Content: View>: View {
    
    @Environment(\.menuRoundness) private var roundness
    @Environment(\.interactionGranularity) private var interactionGranularity
    @Environment(\.isBeingPresentedOn) private var isBeingPresentedOn
    @Environment(\.presentationDepth) private var presentationDepth
    //@Environment(\.isInMenu) private var isInMenu
    //@Environment(\.menuOrder) private var menuOrder
    
    private let content: Content
    
    public init(@ViewBuilder content: @escaping () -> Content){
        self.content = content()
    }
    
    private var width: Double {
        338 - (180 * interactionGranularity)
    }
    
    #if os(macOS)
    private let defaultInsets = EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8)
    private let baseRadius: Double = 18
    #else
    private let defaultInsets = EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 16)
    private let baseRadius: Double = 24
    #endif
    
    public var body: some View {
        VStack(alignment: .leading, spacing: -4){ content }
            .equalInsetContext(defaultInsets: defaultInsets)
            .disabled(isBeingPresentedOn)
            .symbolRenderingMode(.hierarchical)
            .environment(\.isInMenu, true)
            .menuLabeledStyle()
            .toggleStyle(MenuToggleStyle())
            .buttonStyle(MenuButtonStyle())
            .labelStyle(MenuLabelStyle())
            .actionTriggerBehaviour(.onDisappear)
            .opacity(1 - (Double(presentationDepth) * 0.2))
            .padding(baseRadius * 0.25)
            .windowInteractionHoverContext()
            .clipShape(ContainerRelativeShape())
            .background{ MenuBackground() }
            .containerShape(RoundedRectangle(cornerRadius: baseRadius * roundness))
            .frame(maxWidth: width)
            .animation(.smooth, value: roundness)
            .geometryGroupPolyfill()
    }
    
}
