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
                    .foregroundColor(.white)
                    .blendMode(.difference)
                
                Text(string)
                    .font(.system(.title, design: .rounded).weight(.black))
                    .foregroundColor(.white)
                    .blendMode(.difference)
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
