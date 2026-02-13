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
                ExampleMenuPicker(
                    data: [nil] + HorizontalEdge.allCases,
                    selection: $horizontal
                ){ v in
                    Group {
                        if let v {
                            Text("\(v)".splitCamelCaseFormat)
                        } else {
                            Text("None")
                        }
                    }
                } label: {
                    Text("Horizontal")
                }
                
                ExampleMenuPicker(
                    data: [nil] + VerticalEdge.allCases,
                    selection: $vertical
                ){ v in
                    Group {
                        if let v {
                            Text("\(v)".splitCamelCaseFormat)
                        } else {
                            Text("None")
                        }
                    }
                } label: {
                    Text("Vertical")
                }
            }
            .onChangePolyfill(of: horizontal){ update(transition, transitionInverse) }
            .onAppear { update(transition, transitionInverse) }
            .onChangePolyfill(of: vertical){ update(transition, transitionInverse) }
        }
        
    }
    
}



#Preview {
    FlipTransitionExample()
        .previewSize()
}
