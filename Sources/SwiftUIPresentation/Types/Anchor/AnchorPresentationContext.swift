import SwiftUI
import SwiftUIKitCore


struct AnchorPresentationContext: ViewModifier {
    
    typealias Metadata = AnchorPresentationMetadata
    typealias Presentation = PresentationValue<Metadata>
    
    @Environment(\.presentationEnvironmentBehaviour) private var envBehaviour
    @Environment(\.layoutDirection) private var envLayoutDirection
    
    @State private var safeArea: EdgeInsets?
    @State private var isPresentedOn = false
    @State private var root: Presentation?
    
    nonisolated init() { }
    
    private func layoutDirection(for presentation: Presentation) -> LayoutDirection {
        switch envBehaviour {
        case .usePresentation: presentation.layoutDirection
        case .useContext: envLayoutDirection
        }
    }

    func body(content: Content) -> some View {
        content
            .isBeingPresentedOn(isPresentedOn)
            .coordinatedGesture(DragGesture.Value.self)
            .presentationOverlay(Metadata.self){ roots in
                if let root = roots.sorted(by: { $0.sortDate < $1.sortDate }).last {
                    InnerContent(
                        root: root
                    ){
                        isPresentedOn = true
                    }
                    .environment(\.layoutDirection, layoutDirection(for: root))
                    .id(root.id)
                    .onDisappear{ isPresentedOn = false }
                    .onChangePolyfill(of: root){ old, new in
                        if new.id != old.id {
                            old.dispose()
                        }
                    }
                }
            }
            .gestureCoordinator(DragGesture.Value.self)
    }
    
    
    struct InnerContent: View {

        @State private var state: AnchorState?
        @State private var showRoot = false
        @State private var children: [Presentation] = []
        @State private var presented: Set<UniqueID> = []
        @State private var backdropPreference: BackdropPreference?
        
        let root: Presentation
        let didPresent: () -> Void
        
        var body: some View {
            GeometryReader{ proxy in
                AnchorLayout(type: root.type){
                    if showRoot {
                        root.view
                            .anchorLayoutSourceFrame(proxy[root.anchor])
                            .anchorLayoutPaddingContainer()
                            .presentationDismissHandler {
                                showRoot = false
                                root.dispose()
                            }
                            .onChangePolyfill(of: root.wantsDisposal){
                                if root.wantsDisposal {
                                    showRoot = false
                                }
                            }
                        
                    } else {
                        root.view
                            .hidden()
                            .presentationMatchDisabled()
                            .anchorLayoutSourceFrame(proxy[root.anchor])
                            .windowDragDisabled()
                            .onDisappear{
                                // using the inverse to gauge transition animation completion has a drawback that asymetric transitions will use opposite animations
                                if showRoot {
                                    didPresent()
                                }
                            }
                    }
                    
                    ForEach(children){ child in
                        child
                            .view
                            .anchorLayoutSourceFrame(proxy[child.anchor])
                            .anchorLayoutPaddingContainer()
                            .anchorLayoutLeader(child.type, enabled: child.isLeader)
                            .modifier(ChildModifier(
                                show: Binding($presented, contains: child.id),
                                dispose: child.dispose
                            ))
                            .onChangePolyfill(of: child.wantsDisposal){
                                if child.wantsDisposal {
                                    presented.remove(child.id)
                                }
                            }
                    }
                }
            }
            .presentationHandler{ children = $0.sorted(by: { $0.sortDate < $1.sortDate }) }
            .onPresentationBackdropChange{ backdropPreference = $0 }
            .onAppear{ showRoot = true }
            .background {
                if showRoot {
                    BackdropView(
                        preference: backdropPreference,
                        dismiss: {
                            showRoot = false
                            root.dispose()
                        }
                    )
                    .transition((.opacity + .hitTestingDisabled).animation(.smooth))
                }
            }
        }
        
        
        struct ChildModifier: ViewModifier {
            
            @State private var opened = false
            @Binding var show: Bool
            
            let dispose: () -> Void
            
            func body(content: Content) -> some View {
                if show {
                    content
                        .onDisappear{ dispose() }
                        .presentationDismissHandler { show = false; dispose() }
                } else {
                    Color.clear
                        .frame(width: 1, height: 1)
                        .onAppear{
                            guard !opened else { return }
                            show = true
                            opened = true
                        }
                }
            }
            
        }
    }
    
    
}
