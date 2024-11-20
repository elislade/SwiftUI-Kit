import SwiftUIKit

struct ContainedBoundsExample: View {
    
    var body: some View {
        VStack {
            Color.clear
            
            ScrollView {
                VStack(spacing: 0.5) {
                    ForEach(0...100){ i in
                        Cell(i: i)
                        Divider()
                    }
                }
            }
            .containedBoundsContext("Test")
            .scrollClipDisabledPolyfill()
            .border(.tint, width: 6)
            
            Color.clear
        }
        .overlay(alignment: .bottom) {
            ExampleTitle("Contained Bounds")
                .padding()
        }
    }
    
    
    struct Cell: View {
        
        @State private var state: ContainedBoundsState = .notContained
        
        let i: Int
        
        private var opacity: Double {
            switch state {
            case .partiallyContained: 0.5
            case .fullyContained: 1
            case .notContained: 0.15
            }
        }
        
        var body: some View {
            Color.primary
                .opacity(opacity)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .didChangeContainedBounds(in: "Test"){ state = $0 }
                .animation(.fastSpringInterpolating, value: state)
        }
        
    }
    
}


#Preview("Contained Bounds") {
    ContainedBoundsExample()
}
