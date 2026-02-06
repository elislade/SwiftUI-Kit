import SwiftUI
import SwiftUIKitCore

struct FocusPresentationContext: ViewModifier {
    
    typealias Metadata = FocusPresentationMetadata
    
    @Namespace private var ns
    @State private var isBeingPresentedOn = false
    @State private var safeArea: EdgeInsets?
    
    nonisolated init(){}
    
    func body(content: Content) -> some View {
        content
            .isBeingPresentedOn(isBeingPresentedOn)
            .onPresentationSafeAreaChange{ safeArea = $0 }
            .presentationOverlay(Metadata.self){ value in
                if let value = value.last {
                    InnerView(presentation: value){
                        isBeingPresentedOn = true
                    }
                    .onDisappear{ isBeingPresentedOn = false }
                    .id(value.id)
                    .ignoresSafeArea(edges: safeArea != nil ? .all : [])
                }
            }
            .presentationNamespace(ns, active: isBeingPresentedOn)
    }
    
    
    struct InnerView: View {
        
        @Environment(\.layoutDirection) private var layoutDirection
        
        @State private var isFocused = false
        @State private var backdropPreference: BackdropPreference?
        @State private var accessoryIsPresented = false
        
        nonisolated private var focusSizeIncrease: CGFloat { 0 }
        nonisolated private var edgePadding: CGFloat { 16 }
        
        let presentation: PresentationValue<Metadata>
        let didPresent: () -> Void
        
        private func safeOffsets(for rect: CGRect, in size: CGSize) -> CGSize {
            let additional = focusSizeIncrease + edgePadding
            
            let x = layoutDirection == .leftToRight ? rect.minX : size.width - rect.maxX
            
            return CGSize(
                width: max(min(x, size.width - (rect.width + additional)), edgePadding),
                height: max(min(rect.minY, size.height - (rect.height + additional)), edgePadding)
            )
        }
        
        private func safeSize(for rect: CGRect, in size: CGSize) -> CGSize {
            CGSize(
                width: min(rect.width, size.width - (edgePadding * 2)),
                height: min(rect.height, size.height - (edgePadding * 2))
            )
        }
        
        private func dismiss() {
            presentation.dispose()
            isFocused = false
        }
        
        var body: some View {
            GeometryReader { proxy in
                Color.clear.overlay(alignment: .topLeading) {
                    let bounds = proxy[presentation.anchor]
                    let safeSize = safeSize(for: bounds, in: proxy.size)
                    
                    if isFocused {
                        presentation
                            .view
                            .environment(\.reduceMotion, true)
                            .environment(\._isBeingPresented, true)
                            .anchorPresentation(
                                isPresented: $accessoryIsPresented,
                                type: .vertical(preferredAlignment: .center)
                            ){
                                presentation
                                    .accessory()
                                    .transition(.scale(0.1).animation(.bouncy))
                                    .presentationBackdrop(.disabled){ EmptyView() }
                            }
                            .transition((.opacity + .hitTestingDisabled).animation(.easeInOut.speed(1.3)))
                            .matchedGeometryEffect(id: "Item", in: presentation.namespace)
                            .frame(minWidth: safeSize.width, minHeight: safeSize.height)
                            .offset(safeOffsets(for: bounds, in: proxy.size))
                            .geometryGroupIfAvailable()
                            .onAppear{
                                accessoryIsPresented = presentation.accessory() != nil
                            }
                            .onChangePolyfill(of: accessoryIsPresented){
                                if !accessoryIsPresented {
                                    isFocused = false
                                }
                            }
                    } else {
                        Color.clear
                            .transition((.scale(0.999) + .hitTestingDisabled).animation(.bouncy.speed(1.3)))
                            .onDisappear{
                                if isFocused {
                                    didPresent()
                                }
                            }
                    }
                }
                .onPresentationBackdropChange{ backdropPreference = $0 }
                .animation(.bouncy.speed(1.3), value: isFocused)
                .onChangePolyfill(of: isFocused){
                    if !isFocused {
                        dismiss()
                        //accessoryIsPresented = false
                    }
                }
            }
            .presentationDismissHandler {
                dismiss()
            }
            .anchorPresentationContext()
            .background{
                if isFocused {
                    BackdropView(
                        preference: backdropPreference,
                        dismiss: {
                            dismiss()
                            accessoryIsPresented = false
                        }
                    )
                    .transition((.opacity + .hitTestingDisabled).animation(.smooth.speed(1.3)))
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
    
}
