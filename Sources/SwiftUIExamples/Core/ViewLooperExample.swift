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
            ExampleCell.Axis(axis: $axis.animation(.smooth))
                .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Spacing")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(spacing, format: .increment(0.1))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $spacing, in: 0...20)
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Edge Fade")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(edgeFadeAmount, format: .increment(0.1))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $edgeFadeAmount, in: 0...24)
            }
            .exampleParameterCell()
            
            ExampleSection("Animation", isExpanded: true){
                VStack {
                    HStack(spacing: 0) {
                        Text("Speed")
                            .font(.exampleParameterTitle)
                        
                        Spacer(minLength: 10)
                        
                        Text(speed, format: .increment(0.1))
                            .font(.exampleParameterValue)
                    }
                    
                    Slider(value: $speed, in: 0...2)
                }
                .exampleParameterCell()
                
                VStack {
                    HStack {
                        Text("Delay")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(delay, format: .increment(0.1))
                            .font(.exampleParameterValue)
                        +
                        
                        Text(" Seconds")
                            .font(.caption2)
                            .foregroundColor(.primary.opacity(0.5))
                    }
                    
                    Slider(value: $delay, in: 0...10)
                }
                .exampleParameterCell()
            }
        }
    }
}


#Preview("View Looper") {
    ViewLooperExample()
        .previewSize()
}
