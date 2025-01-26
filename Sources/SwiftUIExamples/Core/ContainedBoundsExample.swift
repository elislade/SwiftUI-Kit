import SwiftUIKit


public struct ContainedBoundsExample: View {
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 30) {
            RoundedRectangle(cornerRadius: 30)
                .fill(.secondary.opacity(0.2))
                .overlay {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        ScrollView {
                            VStack(spacing: 1) {
                                ForEach(0...100){ i in
                                    Cell(i: i)
                                }
                            }
                        }
                        .containedBoundsContext("Test")
                        .scrollClipDisabledPolyfill()
                        .border(.tint, width: 2)
                        .aspectRatio(2, contentMode: .fit)
                        
                        Spacer()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 30))

            ExampleTitle("Contained Bounds")
        }
        .padding()
    }
    
    
    struct Cell: View {
        
        @State private var state: ContainedBoundsState?
        
        let i: Int
        
        private var opacity: Double {
            guard let state else { return 0 }
            switch state.containment {
            case .partially: return 0.5
            case .fully: return 1
            case .none:return 0.15
            }
        }
        
        var body: some View {
            Color.primary
                .opacity(opacity)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .onContainedBoundsChange(in: "Test"){ state = $0 }
                .animation(.fastSpringInterpolating, value: state)
        }
        
    }
    
}


#Preview("Contained Bounds") {
    ContainedBoundsExample()
        .previewSize()
}
