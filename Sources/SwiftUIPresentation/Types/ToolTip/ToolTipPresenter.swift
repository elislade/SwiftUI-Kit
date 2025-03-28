import SwiftUI
import SwiftUIKitCore

struct ToolTipPresenter<Tip: View>: ViewModifier {
    
    @FocusState private var isFocused: Bool
    @State private var isHovering = false
    
    private var shouldPresent: Bool { isFocused || isHovering }
    
    @State private var internalIsPresented = false
    private var externalIsPresented: Binding<Bool>?
    
    private var isPresented: Binding<Bool> {
        externalIsPresented ?? $internalIsPresented
    }
    
    let edge: Edge
    let tip: @MainActor () -> Tip

    nonisolated private var sourceAnchor: UnitPoint {
        UnitPoint(edge)
    }
    
    nonisolated init(
        edge: Edge,
        isPresented: Binding<Bool>? = nil,
        content: @MainActor @escaping () -> Tip
    ) {
        self.externalIsPresented = isPresented
        self.edge = edge
        self.tip = content
    }
    
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .focused($isFocused)
            .onHoverPolyfill{ isHovering = $0 }
            .task(id: shouldPresent) {
                if let _ = try? await Task.sleep(nanoseconds: NSEC_PER_SEC) {
                    isPresented.wrappedValue = shouldPresent
                }
            }
            .autoAnchorOrthogonalToEdgePresentation(isPresented: isPresented, edge: edge){
                tip()
                    #if !os(tvOS)
                    .onTapGesture { isPresented.wrappedValue = false }
                    #endif
                    .toolTipPresentationStyle()
            }
    }
    
}

extension View {
    
    func toolTipPresentationStyle() -> some View {
        presentationBackdrop(.disabled){ Color.clear }
        .font(.caption.weight(.semibold))
        .padding(3)
        .padding(.horizontal, 3)
        .background{
            RoundedRectangle(cornerRadius: 6)
                .fill(.background)
                .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
            
            RoundedRectangle(cornerRadius: 6)
                .inset(by: -1)
                .strokeBorder()
                .opacity(0.1)
        }
        .padding(2)
        .transition((.scale(0.8) + .opacity).animation(.bouncy))
    }
    
}
