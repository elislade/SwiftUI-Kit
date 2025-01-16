import SwiftUIKit


public struct FlipExamplesView: View {
    
    @State private var isFlipped = false
    @State private var horizontal: HorizontalEdge? = .leading
    @State private var vertical: VerticalEdge? = .top
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Flip"){
            AxisStack(isFlipped ? .vertical : .horizontal) {
                ForEach(1...2){ i in
                    Card(name: "Front \(i)")
                        .flippedContent(
                            active: isFlipped,
                            horizontalEdge: horizontal,
                            verticalEdge: vertical
                        ){
                            Card(name: "Back \(i)", aspect: 1.8)
                        }
                }
            }
            .padding()
            .animation(.bouncy, value: horizontal)
            .animation(.bouncy, value: vertical)
            .animation(.bouncy, value: isFlipped)
        } parameters: {
            HStack {
                Text("Actions")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Button("Random Flip"){
                    vertical = Bool.random() ? .allCases.randomElement() : .none
                    horizontal = Bool.random() ? .allCases.randomElement() : .none
                    isFlipped.toggle()
                }
                .font(.exampleParameterValue)
            }
            .exampleParameterCell()
            
            Toggle(isOn: $isFlipped){
                Text("Is flipped")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            HStack {
                Text("Vertical Direction")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $vertical){
                    Text("None").tag(Optional<VerticalEdge>(nil))
                    Text("Top").tag(Optional(VerticalEdge.top))
                    Text("Bottom").tag(Optional(VerticalEdge.bottom))
                }
            }
            .exampleParameterCell()
            
            HStack {
                Text("Horizontal Direction")
                    .font(.exampleParameterTitle)
                    .fixedSize()
                
                Spacer()
                
                Picker("", selection: $horizontal){
                    Text("None").tag(Optional<HorizontalEdge>(nil))
                    Text("Leading").tag(Optional(HorizontalEdge.leading))
                    Text("Trailing").tag(Optional(HorizontalEdge.trailing))
                }
            }
            .exampleParameterCell()
        }
    }
    
    
    struct Card: View {
        let name: String
        var aspect = 1.5
        
        var body: some View {
            SunkenControlMaterial(RoundedRectangle(cornerRadius: 20), isTinted: true)
                .tint(.random)
                .overlay(Text(name).foregroundStyle(.white).blendMode(.exclusion))
                .aspectRatio(aspect, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .font(.title.bold())
        }
    }
    
}


#Preview("Flip") {
    FlipExamplesView()
        .previewSize()
}
