import SwiftUIKit


public struct FlipExamplesView: View {
    
    @State private var isFlipped = false
    @State private var horizontal: HorizontalEdge? = .leading
    @State private var vertical: VerticalEdge? = .top
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Flip"){
            Card(name: "Front")
                .flippedContent(
                    active: isFlipped,
                    horizontalEdge: horizontal,
                    verticalEdge: vertical
                ){
                    Card(name: "Back", aspect: 1.8)
                }
                .padding()
                .frame(maxWidth: 600)
                .animation(.bouncy, value: horizontal)
                .animation(.bouncy, value: vertical)
                .animation(.bouncy, value: isFlipped)
        } parameters: {
            HStack {
                Toggle(isOn: $isFlipped.animation(.bouncy)){
                    Text("Flipped")
                }
                .fixedSize()
                
                Button{
                    vertical = Bool.random() ? .allCases.randomElement() : .none
                    horizontal = Bool.random() ? .allCases.randomElement() : .none
                    isFlipped.toggle()
                } label: {
                    Label("Random", systemImage: "dice")
                }
                
            }
            
            ExampleMenuPicker(
                data: [nil, .top, .bottom],
                selection: $vertical
            ){ dir in
                if let dir {
                    Text("\(dir)".capitalized)
                } else {
                    Text("None")
                }
            } label: {
                Text("Vertical Direction")
            }
            
            ExampleMenuPicker(
                data: [nil, .leading, .trailing],
                selection: $horizontal
            ){ dir in
                if let dir {
                    Text("\(dir)".capitalized)
                } else {
                    Text("None")
                }
            } label: {
                Text("Horizontal Direction")
            }
        }
    }
    
    
    struct Card: View {
        let name: String
        var aspect = 1.5
        
        var body: some View {
            SunkenControlMaterial(RoundedRectangle(cornerRadius: 20), isTinted: true)
                .tint(.random)
                .overlay{
                    Text(name)
                        .foregroundStyle(.white)
                        .blendMode(.exclusion)
                        .padding(10)
                }
                .minimumScaleFactor(0.1)
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
