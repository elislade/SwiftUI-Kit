import SwiftUIKit


public struct AxisStackExampleView : View {
    
    @State private var axis: Axis = .vertical
    @State private var alignment: Alignment = .center
    @State private var spacing: Double = 0
    @State private var items: [Color] = [.random, .random, .random, .random]
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Axis Stack"){
            AxisStack(axis, alignment: alignment, spacing: spacing){
                ForEach(items.indices, id: \.self){ i in
                    items[i]
                }
            }
            .animation(.smooth, value: axis)
        } parameters: {
            HStack {
                Text("Axis")
                    .font(.title3[.semibold])
                
                Spacer()
                
                Picker("", selection: $axis){
                    Text("Horizontal").tag(Axis.horizontal)
                    Text("Vertical").tag(Axis.vertical)
                }
            }
            .padding()
            
            Divider()
            
            VStack {
                HStack {
                    Text("Spacing")
                        .font(.title3[.semibold])
                    
                    Spacer()
                }
                
                Slider(value: $spacing, in: 0...30)
            }
            .padding()
        }
    }
    
}


#Preview("Axis Stack") {
    AxisStackExampleView()
        .previewSize()
}
