import SwiftUIKit


public struct AnimationThresholdChangeExample : View {
    
    @State private var animate = false
    @State private var show = false
    @State private var threshold: Double = 0.5
    
    let duration: TimeInterval = 2
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Animation Threshold Change"){
            let shape = ContainerRelativeShape()
            ZStack {
                shape
                    .strokeBorder(lineWidth: 10)
                    .opacity(0.1)
                
                shape
                    .inset(by: 5)
                    .trim(from: 0, to: animate ? 1 : 0)
                    .stroke(lineWidth: 10)
                    .foregroundStyle(
                        .conicGradient(colors: [.primary.opacity(0.2), .primary], center: .center)
                    )
                
                shape
                    .inset(by: 5)
                    .trim(from: threshold - 0.002, to: threshold + 0.002)
                    .stroke(lineWidth: 10)
                    .foregroundStyle(.tint)
                
                if show {
                    shape
                        .inset(by: 16)
                        .transition(.scale.animation(.bouncy))
                }
            }
            .onAnimationThresholdChange(threshold, active: animate){
                show.toggle()
            }
            .overlay(alignment: .trailing){
                Image(systemName: "arrow.down")
                    .resizable()
                    .scaledToFit()
                    .font(.body[.heavy])
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 10, height: 10)
                    .rotationEffect(.degrees(show ? 180 : 0))
                    .foregroundStyle(.tint)
                    .animation(.smooth, value: show)
            }
            .padding()
            .drawingGroup()
            .animation(.linear(duration: duration), value: animate)
        } parameters: {
            Toggle(isOn: $animate){
                Text("Show")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Threshold")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(threshold, format: .increment(0.01))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $threshold)
            }
            .exampleParameterCell()
        }
    }
    
}


#Preview("Animation Threshold Change") {
    AnimationThresholdChangeExample()
        .previewSize()
}
