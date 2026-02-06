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
    
    private var type: PresentedAnchorType {
        switch axis {
        case .vertical: .vertical(preferredAlignment: .center)
        case .horizontal: .horizontal(preferredAlignment: .center)
        }
    }
    
    let axis: Axis
    let tip: @MainActor () -> Tip
    
    nonisolated init(
        axis: Axis,
        isPresented: Binding<Bool>? = nil,
        content: @MainActor @escaping () -> Tip
    ) {
        self.externalIsPresented = isPresented
        self.axis = axis
        self.tip = content
    }
    
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .focused($isFocused)
            .onHoverPolyfill{ isHovering = $0 }
            .task(id: shouldPresent, priority: .low) {
                if let _ = try? await Task.sleep(for: .seconds(0.3)) {
                    isPresented.wrappedValue = shouldPresent
                }
            }
            .anchorPresentation(
                isPresented: isPresented,
                type: type
            ){
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
            RoundedRectangle(cornerRadius: 8)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
            
            RoundedRectangle(cornerRadius: 8)
                .inset(by: -0.5)
                .strokeBorder(.black, lineWidth: 0.5)
                .opacity(0.4)
            
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.white)
                .opacity(0.1)
        }
        .padding(2)
        .transition((.scale(0.8, anchor: .topLeading) + .opacity).animation(.bouncy))
    }
    
}
