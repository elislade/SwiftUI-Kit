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
        Text(string)
            .font(.system(.title, design: .rounded)[.black][.monospacedDigit])
            .padding(5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .lineLimit(1)
            .minimumScaleFactor(0.2)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.background)
                
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(lineWidth: 1)
            }
    }
}


#Preview {
    ExampleTile("Hello")
        .padding()
}
