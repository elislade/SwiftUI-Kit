import SwiftUIKit


public struct InlineBindingExample: View {
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            InlineBinding(ColorScheme.light){ binding in
                ZStack {
                    Rectangle()
                        .fill(.background)
                        .ignoresSafeArea()
                    
                    SegmentedPicker(
                        selection: binding.animation(.bouncy),
                        items: [.light, .dark]
                    ){ scheme in
                        Text("\(scheme)".capitalized)
                            .font(.title3[.bold])
                    }
                    .frame(maxWidth: 200)
                    .controlSize(ControlSize.large)
                    .controlRoundness(1)
                }
                .environment(\.colorScheme, binding.wrappedValue)
            }
            
            Divider().ignoresSafeArea()
            
            ExampleTitle("Inline Binding")
                .padding()
        }
    }
    
}

#Preview {
    InlineBindingExample()
        .previewSize()
}
