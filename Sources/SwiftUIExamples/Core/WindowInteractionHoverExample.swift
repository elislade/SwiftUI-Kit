import SwiftUIKit


public struct WindowInteractionHoverExample: View {

    public init(){}
    
    public var body: some View {
        VStack(spacing: 16) {
            ExampleTitle("Window Interaction Hover")
            
            VStack(spacing: 5) {
                ForEach(0..<3) { _ in
                    HStack(spacing: 5) {
                        ForEach(0..<3) { _ in
                            Element()
                        }
                    }
                }
            }
        }
        .padding()
        .windowInteractionHoverContext()
    }
    
    
    struct Element: View {
        
        @State private var phase: WindowInteractionHoverPhase?
        
        var body: some View {
            RoundedRectangle(cornerRadius: 30)
                .opacity(phase == .entered || phase == .ended ? 1 : 0.2)
                .onWindowInteractionHover{ phase = $0 }
                .overlay {
                    Group {
                        if let phase {
                            Image(systemName: {
                                switch phase {
                                case .entered: "square.and.arrow.down"
                                case .left: "square.and.arrow.up"
                                case .ended: "checkmark"
                                }
                            }())
                        }
                    }
                    .font(.largeTitle.weight(.bold))
                    .blendMode(.destinationOut)
                }
                .symbolEffectBounce(value: phase, grouping: .byLayer)
                .compositingGroup()
        }
    }
    
}


#Preview {
    WindowInteractionHoverExample()
        .previewSize()
}
