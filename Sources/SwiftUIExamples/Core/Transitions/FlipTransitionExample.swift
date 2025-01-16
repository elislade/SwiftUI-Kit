import SwiftUIKit


public struct FlipTransitionExample: View {
    
    public init() {}
    
    public var body: some View {
        TransitionExampleView<Parameters>()
    }
    
    
    struct Parameters : TransitionProviderView {
        
        static var name: String = "Flip Transition"
        
        var update: (_ normal: AnyTransition, _ inverse: AnyTransition?) -> Void = { _, _ in }
        
        @State private var horizontal: HorizontalEdge? = .trailing
        @State private var vertical: VerticalEdge?
        
        private var transition: AnyTransition {
            if horizontal != nil && vertical != nil {
                return .flip(horizontal: horizontal!, vertical: vertical!)
            } else if horizontal != nil {
                return .flipHorizontal(horizontal!)
            } else if vertical != nil {
                return .flipVertical(vertical!)
            }
            return .identity
        }
        
        private var transitionInverse: AnyTransition {
            if horizontal != nil && vertical != nil {
                return .flip(horizontal: horizontal!.inverse, vertical: vertical!.inverse)
            } else if horizontal != nil {
                return .flipHorizontal(horizontal!.inverse)
            } else if vertical != nil {
                return .flipVertical(vertical!.inverse)
            }
            return .identity
        }
        
        var body: some View {
            HStack {
                Text("Horizontal")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $horizontal) {
                    ForEach(HorizontalEdge.allCases, id: \.rawValue) { edge in
                        Text("\(edge)".splitCamelCaseFormat).tag(edge)
                    }
                    
                    Text("None").tag(Optional<HorizontalEdge>(nil))
                }
            }
            .exampleParameterCell()
            .onChangePolyfill(of: horizontal){ update(transition, transitionInverse) }
            .onAppear { update(transition, transitionInverse) }
            
            HStack {
                Text("Vertical")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $vertical) {
                    ForEach(VerticalEdge.allCases, id: \.rawValue) { edge in
                        Text("\(edge)".splitCamelCaseFormat).tag(edge)
                    }
                    
                    Text("None").tag(Optional<VerticalEdge>(nil))
                }
            }
            .exampleParameterCell()
            .onChangePolyfill(of: vertical){ update(transition, transitionInverse) }
        }
        
    }
    
}



#Preview {
    FlipTransitionExample()
        .previewSize()
}
