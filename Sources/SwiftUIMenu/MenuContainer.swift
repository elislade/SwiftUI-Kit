import SwiftUI
import SwiftUIKitCore
import SwiftUIPresentation


public struct MenuContainer<Content: View>: View {
    
    @Namespace private var ns
    
    @State private var useScrollView: Bool = false
    @State private var hapticSelection: Bool = false
    
    @Environment(\.menuRoundness) private var roundness
    @Environment(\.menuWidthConstrained) private var constrainWidth
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
    private let defaultInsets = EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
    private let baseRadius: Double = 24
    #endif
    
    
    private var innerContent: some View {
        VStack(alignment: .leading, spacing: 0){
            content//.background(alignment: .bottom){ Divider() }
        }
        .equalInsetContext(defaultInsets: defaultInsets)
        .disabled(isBeingPresentedOn)
        .symbolRenderingMode(.hierarchical)
        .environment(\.isInMenu, true)
        .menuLabeledStyle()
        .toggleStyle(MenuToggleStyle())
        .buttonStyle(.menu)
        .labelStyle(MenuLabelStyle())
        .presentationNamespace(ns)
        .actionTriggerBehaviour(.onDisappear)
        .opacity(1 - (Double(presentationDepth) * 0.2))
        .sensoryFeedbackPolyfill(value: hapticSelection)
        .onGeometryChangePolyfill(of: { $0.size.height > 500 }){ useScrollView = $0 }
    }
    
    public var body: some View {
        ZStack {
            if useScrollView {
                ScrollView(.vertical){
                    innerContent
                        .environment(\.isInMenuScroll, true)
                }
                .clipShape(ContainerRelativeShape())
                .background{ MenuBackground() }
                .containerShape(RoundedRectangle(cornerRadius: baseRadius * roundness))
                .frame(width: constrainWidth ? width : nil)
                .animation(.smooth, value: roundness)
                .geometryGroupIfAvailable()
            } else {
                innerContent
                    .clipShape(ContainerRelativeShape())
                    .interactionHoverGroup(priority: .window){ evt in
                        if evt.phase == .entered {
                            hapticSelection.toggle()
                        }
                    }
                    .background{ MenuBackground() }
                    .containerShape(RoundedRectangle(cornerRadius: baseRadius * roundness))
                    .frame(width: constrainWidth ? width : nil)
                    .animation(.smooth, value: roundness)
                    .geometryGroupIfAvailable()
            }
        }
    }
    
}


extension EnvironmentValues {
    
    @Entry var isInMenuScroll: Bool = false
    @Entry var menuWidthConstrained: Bool = true
    
}

extension View {
    
    nonisolated public func menuWidthConstrained(_ constrained: Bool = true) -> some View {
        environment(\.menuWidthConstrained, constrained)
    }
    
}
