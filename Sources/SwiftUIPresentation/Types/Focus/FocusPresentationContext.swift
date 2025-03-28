import SwiftUI

struct FocusPresentationContext: ViewModifier {
    
    @Environment(\.layoutDirection) private var layoutDirection
    @Namespace private var ns
    
    @State private var bgInteraction: PresentationBackdropInteraction?
    @State private var bg: PresentationBackdropKeyValue?
    
    private var bgView: AnyView? { bg?.view() }
    
    @State private var focusedView: AnyView?
    @State private var accessoryIsPresented = false
    
    nonisolated private var focusSizeIncrease: CGFloat { 0 }
    nonisolated private var edgePadding: CGFloat { 16 }

    nonisolated init(){}
    
    private func safeOffsets(for rect: CGRect, in size: CGSize) -> CGSize {
        let additional = focusSizeIncrease + edgePadding
        
        let x = layoutDirection == .leftToRight ? rect.minX : size.width - rect.maxX
        
        return CGSize(
            width: max(min(x, size.width - (rect.width + additional)), edgePadding),
            height: max(min(rect.minY, size.height - (rect.height + additional)), edgePadding)
        )
    }
    
    private func safeSize(for rect: CGRect, in size: CGSize) -> CGSize {
        let maxWidth = size.width - (edgePadding * 2)
        let maxHeight = size.height - (edgePadding * 2)
        
        return CGSize(
            width: min(rect.width, maxWidth),
            height: min(rect.height, maxHeight)
        )
    }
    
    private func dismiss(_ value: PresentationValueConformable) {
        focusedView = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            value.dispose()
        }
    }

    func body(content: Content) -> some View {
        content
            .isBeingPresentedOn(focusedView != nil)
            .sensoryFeedbackPolyfill(.impact(style: .rigid, intensity: 1), value: focusedView == nil)
            .overlayPreferenceValue(PresentationKey<FocusPresentationMetadata>.self){ value in
                GeometryReader { proxy in
                    if let value = value.last {
                        ZStack(alignment: .topLeading) {
                            PresentationBackground(
                                bgView: bgView,
                                bgInteraction: bgInteraction,
                                dismiss: {
                                    if accessoryIsPresented {
                                        accessoryIsPresented = false
                                    } else {
                                        dismiss(value)
                                    }
                                }
                            )
                            .opacity(focusedView != nil ? 1 : 0)
                            
                            let bounds = proxy[value.anchor]
                            let safeSize = safeSize(for: bounds, in: proxy.size)
                            
                            if let focusedView {
                                focusedView
                                    .environment(\.reduceMotion, true)
                                    .environment(\._isBeingPresented, true)
                                    .matchedGeometryEffect(id: "View", in: ns)
                                    .zIndex(2)
                                    .onPreferenceChange(PresentationBackdropKey.self){
                                        _bg.wrappedValue = $0.last
                                    }
                                    .onPreferenceChange(PresentationBackdropInteractionKey.self){
                                        _bgInteraction.wrappedValue = $0.last
                                    }
                                    .autoAnchorPresentation(isPresented: $accessoryIsPresented){ state in
                                        value
                                            .metadata.accessory(state)
                                            .presentationBackdrop(.disabled){ EmptyView() }
                                    }
                                    .frame(width: safeSize.width, height: safeSize.height)
                                    .offset(safeOffsets(for: bounds, in: proxy.size))
                                    .shadow(color: .black.opacity(0.2), radius: 30, y: 5)
                            } else {
                                value
                                    .metadata
                                    .sourceView()
                                    .environment(\.reduceMotion, true)
                                    .zIndex(2)
                                    .frame(width: bounds.width, height: bounds.height)
                                    .matchedGeometryEffect(id: "View", in: ns)
                                    .offset(
                                        x: layoutDirection == .rightToLeft ? proxy.size.width - bounds.maxX : bounds.minX,
                                        y: bounds.minY
                                    )
                            }
                        }
                        .animation(.bouncy.speed(1.3), value: focusedView == nil)
                        .animation(.bouncy.speed(1.3), value: accessoryIsPresented)
                        .anchorPresentationContext()
                        .onChangePolyfill(of: accessoryIsPresented){
                            if !accessoryIsPresented {
                                dismiss(value)
                            }
                        }
                        .onAppear {
                            focusedView = value.view()
                            // use stub state to initially find out if the closure returns a view or not.
                            let stubState = AutoAnchorState(anchor: .bottom, edge: .bottom)
                            accessoryIsPresented = value.metadata.accessory(stubState) != nil
                        }
                    }
                }
            }
    }
    
}
