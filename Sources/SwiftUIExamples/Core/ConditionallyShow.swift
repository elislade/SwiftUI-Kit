import SwiftUIKit


struct ConditionallyShowExample : View {
    
    @State private var show = false
    @State private var threshold: Double = 0.5
    
    let duration: TimeInterval = 2
    
    var body: some View {
        ExampleView(title: "Conditionally Show"){
            let shape = RoundedRectangle(cornerRadius: 30)
            ZStack {
                shape
                    .strokeBorder(lineWidth: 10)
                    .opacity(0.1)
                
                shape
                    .inset(by: 5)
                    .trim(from: 0, to: show ? 1 : 0)
                    .stroke(lineWidth: 10)
                    .foregroundStyle(
                        .conicGradient(colors: [.primary.opacity(0.2), .primary], center: .center)
                    )
                
                shape
                    .inset(by: 5)
                    .trim(from: threshold - 0.002, to: threshold + 0.002)
                    .stroke(lineWidth: 10)
                    .foregroundStyle(.tint)
                
                shape
                    .inset(by: 16)
                    .transition(.scale.animation(.bouncy))
                    .conditonallyShow(
                        animatingCondition: show,
                        threshold: threshold
                    )
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
                    .animation(.smooth.delay(duration * threshold), value: show)
            }
            .padding()
            .drawingGroup()
            .aspectRatio(1, contentMode: .fit)
            .animation(.linear(duration: duration), value: show)
        } parameters: {
            Toggle(isOn: $show){
                Text("Show")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            VStack {
                HStack {
                    Text("Threshold")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(threshold, format: .number.rounded(increment: 0.1))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $threshold)
            }
            .exampleParameterCell()
        }
    }
    
}


#Preview("Conditionally Show") {
    ConditionallyShowExample()
        .previewSize()
}
