import SwiftUIKit


public struct ViewLooperExample: View {
    
    @State private var axis: Axis = .horizontal
    @State private var spacing: Double = 10
    @State private var edgeFadeAmount: Double = 12
    @State private var speed: Double = 1
    @State private var delay: Double = 0.3
    @State private var tapped: Int?
    
    public nonisolated init() {}
    
    public var body: some View {
        ExampleView(title: "View Looper"){
            ViewLooper(
                axis,
                spacing: spacing,
                animation: .dynamic{ dimension in
                    .easeInOut(duration: dimension * (5 / 1000))
                    .speed(speed)
                    .delay(delay)
                },
                edgeFadeAmount: edgeFadeAmount
            ) {
                AxisStack(axis, spacing: 10) {
                    ForEach(1..<5){ i in
                        Button { tapped = i } label: {
                            ExampleTile(i)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
            .buttonStyle(.tinted)
            .id(speed).id(delay).id(axis).id(spacing)
            .frame(
                width: axis == .vertical ? 70 : nil,
                height: axis == .horizontal ? 70 : nil
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: axis == .horizontal ? .top : .leading) {
                if let tapped {
                    Text(tapped, format: .number)
                        .font(.title2[.bold].monospacedDigit())
                }
            }
            .padding()
        } parameters: {
            ExampleSection(isExpanded: true){
                ExampleCell.Axis(axis: $axis.animation(.smooth))
                
                HStack {
                    ExampleSlider(value: .init($spacing, in: 0...20)){
                        Text("Spacing")
                    }
                    
                    ExampleSlider(value: .init($edgeFadeAmount, in: 0...24)){
                        Text("Edge Fade")
                    }
                }
            } label: {
                Text("Parameters")
            }
            
            ExampleSection(isExpanded: true){
                HStack {
                    ExampleSlider(value: .init($speed, in: 0...2)){
                        Label("Speed", systemImage: "hare.fill")
                    }
                    
                    ExampleSlider(value: .init($delay, in: 0...10)){
                        Label("Delay", systemImage: "clock.fill")
                    }
                }
            } label: {
                Text("Animation")
            }
        }
    }
}


#Preview("View Looper") {
    ViewLooperExample()
        .previewSize()
}
