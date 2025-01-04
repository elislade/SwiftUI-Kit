import SwiftUIKit


public struct LineShapeExample: View {
    
    @State private var thickness: Double = 6
    @State private var axis: Axis = .vertical
    @State private var anchor: UnitPoint = .center
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Line Shape") {
            LineShape(axis: axis, anchor: anchor)
                .stroke(lineWidth: thickness)
                .padding()
        } parameters: {
            VStack {
                HStack {
                    Text("Thickness")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(thickness, format: .number.rounded(increment: 0.1))
                }
                
                Slider(value: $thickness, in: 0.5...30)
                    .font(.exampleParameterValue)
            }
            .padding()
            
            Divider()
            
            HStack {
                Text("Axis")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $axis){
                    Text("Horizontal").tag(Axis.horizontal)
                    Text("Vertical").tag(Axis.vertical)
                }
            }
            .padding()
            
            Divider()
            
            if axis == .vertical {
                VStack {
                    HStack {
                        Text("Anchor X")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(anchor.x, format: .number.rounded(increment: 0.1))
                            .font(.exampleParameterValue)
                    }
                    
                    Slider(value: $anchor.x)
                }
                .padding()
                
                Divider()
            } else {
                VStack {
                    HStack {
                        Text("Anchor Y")
                            .font(.exampleParameterTitle)
                        
                        Spacer()
                        
                        Text(anchor.y, format: .number.rounded(increment: 0.1))
                            .font(.exampleParameterValue)
                    }
                    
                    Slider(value: $anchor.y)
                }
                .padding()
                
                Divider()
            }
        }
    }
    
}


#Preview("Line Shape") {
    LineShapeExample()
        .previewSize()
}
