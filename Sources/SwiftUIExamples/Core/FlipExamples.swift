import SwiftUIKit


struct FlipExamplesView: View {
    
    @State private var isFlipped = false
    @State private var horizontal: HorizontalEdge? = .leading
    @State private var vertical: VerticalEdge? = .top
    
    var body: some View {
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
            .onTapGesture {
                vertical = .allCases.randomElement()
                horizontal = .allCases.randomElement()
                isFlipped.toggle()
            }
        } parameters: {
            Toggle(isOn: $isFlipped){
                Text("Is flipped")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
            
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
            .padding()
            
            Divider()
            
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
            .padding()
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
}
