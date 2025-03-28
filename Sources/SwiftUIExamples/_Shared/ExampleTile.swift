import SwiftUIKit


struct ExampleTile: View {
    
    let string: String
    
    init(_ number: Int) {
        self.string = "\(number)"
    }
    
    init(_ string: String) {
        self.string = string
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(lineWidth: 1)
                    .colorInvert()
                
                Text(string)
                    .font(.system(.title, design: .rounded)[.black][.monospacedDigit])
                    .colorInvert()
                    .padding(5)
            }
            .drawingGroup()
            .lineLimit(1)
            .minimumScaleFactor(0.2)
    }
}


#Preview {
    ExampleTile("Hello")
        .padding()
}
