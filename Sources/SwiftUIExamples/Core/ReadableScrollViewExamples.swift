import SwiftUIKit


struct ReadableScrollViewExample : View {
    
    @Environment(\.reset) private var reset
    @State private var size: Double = 1000
    @State private var offset = CGPoint()
    @State private var axis: Axis.Set = [.vertical]
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Readable Scroll View"){
            ReadableScrollView(
                axis,
                contentOffset: { offset = $0 }
            ) {
                ZStack {
                    if axis.contains(.horizontal) {
                        HStack(spacing: 0){
                            ForEach(0...100){ i in
                                Color.primary
                                    .frame(width: 1)
                                    .frame(maxWidth: .infinity)
                                    .opacity(i.isMultiple(of: 10) ? 0.3 : 0.1)
                            }
                        }
                        .frame(
                            width: size,
                            height: axis.contains(.vertical) ? size : nil
                        )
                    }
                    
                    if axis.contains(.vertical) {
                        VStack(spacing: 0){
                            ForEach(0...100){ i in
                                Color.primary
                                    .frame(height: 1)
                                    .frame(maxHeight: .infinity)
                                    .opacity(i.isMultiple(of: 10) ? 0.3 : 0.1)
                            }
                        }
                        .frame(
                            width: axis.contains(.horizontal) ? size : nil,
                            height: size
                        )
                    }
                }
                .ignoresSafeArea()
            }
            .safeAreaInset(edge: .bottom, spacing: 0){
                HStack {
                    Image(systemName: "arrow.left.and.right.circle.fill")
                    Text(offset.x, format: .increment(0.1))
                    Spacer(minLength: 20)
                    Text(offset.y, format: .increment(0.1))
                    Image(systemName: "arrow.up.and.down.circle.fill")
                }
                .padding()
                .font(.title[.semibold][.monospacedDigit])
                .symbolRenderingMode(.hierarchical)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
            }
        } parameters: {
            Toggle(isOn: Binding($axis, contains: .horizontal)){
                Label("Horizontal Axis", systemImage: "arrow.left.and.right")
            }
            
            Toggle(isOn: Binding($axis, contains: .vertical)){
                Label("Vertical Axis", systemImage: "arrow.up.and.down")
            }
            
            Button{ reset() } label: {
                Label("Reset", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }

            ExampleSlider(value: .init($size, in: 300...1300, step: 10)){
                Label("Size", systemImage: "ruler.fill")
            }
        }
    }
    
}


#Preview("Readable Scroll View") {
    ReadableScrollViewExample()
        .previewSize()
}
