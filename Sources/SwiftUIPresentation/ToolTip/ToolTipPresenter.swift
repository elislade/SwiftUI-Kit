import SwiftUI
import SwiftUIKitCore

struct ToolTipPresenter<Tip: View>: ViewModifier {
    
    @State private var isShowing = false
    @State private var showingTask: DispatchWorkItem?
    @Binding private var isPresented: Bool
    
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
        self._isPresented = isPresented ?? .constant(false)
        self.edge = edge
        self.tip = content
    }
    
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onHover{ hovering in
                showingTask?.cancel()
                let item = DispatchWorkItem{ isShowing = hovering }
                showingTask = item
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: item)
            }
            .onDisappear{ showingTask?.cancel() }
            .onChange(of: isPresented){ isShowing = $0 }
            .onChange(of: isShowing){
                guard isPresented != $0 else { return }
                isPresented = $0
            }
            .onAppear{ isShowing = isPresented }
            .autoAnchorOrthogonalToEdgePresentation(isPresented: $isShowing, edge: edge){
                tip()
                    .presentationBackground(.disabled){ Color.clear }
                    .onTapGesture { isShowing = false }
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
}
