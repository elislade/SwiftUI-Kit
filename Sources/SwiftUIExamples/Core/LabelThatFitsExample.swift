import SwiftUIKit


public struct LabelThatFitsExample: View {
    
    @State private var suggestion: LayoutDirectionSuggestion = .useSystemDefault
    
    @SliderState private var height = 40
    @SliderState private var width = 40
    @State private var prefersTitle: Bool = true
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Label That Fits"){
            Color.clear.onGeometryChangePolyfill(of: \.size){ size in
                _height.bounds = (size.height / 10)...size.height
                _width.bounds = (size.width / 10)...size.width
            }
            .overlay {
                Rectangle()
                    .fill(.tint)
                    .frame(width: width, height: height)
                
                HStack {
                    Label("Leading", systemImage: "apple.logo")
                        .frame(maxWidth: .infinity)
                    
                    Rectangle()
                        .frame(width: width, height: 0)
                    
                    Label("Trailing", systemImage: "apple.logo")
                        .frame(maxWidth: .infinity)
                }
                
                VStack {
                    Label("Top", systemImage: "apple.logo")
                        .frame(maxHeight: .infinity)
                    
                    Rectangle()
                        .frame(width: 0, height: height)
                    
                    Label("Bottom", systemImage: "apple.logo")
                        .frame(maxHeight: .infinity)
                }
            }
            .environment(\.layoutDirectionSuggestion, suggestion)
            .labelStyle(
                prefersTitle ? .viewThatFits(preferring: \.title) : .viewThatFits(preferring: \.icon)
            )
        } parameters: {
            VStack {
                HStack {
                    Text("Size")
                        .font(.exampleParameterTitle)
                    
                    Spacer(minLength: 0)
                    
                    Group {
                        Text(width, format: .increment(1)) + Text(" , ") + Text(height, format: .increment(1))
                    }
                    .font(.exampleParameterValue)
                }
                
                HStack {
                    Slider(_width)
                    Slider(_height)
                }
            }
            .exampleParameterCell()
            
            HStack {
                Text("Prefers")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                SegmentedPicker(selection: $prefersTitle.animation(.smooth), items: [true, false]){
                    Text($0 ? "Title" : "Icon")
                }
                .frame(width: 130)
                .controlRoundness(1)
            }
            .exampleParameterCell()
            
            ExampleCell.LayoutDirectionSuggestion(value: $suggestion)
            
        }
    }
    
}


#Preview("Label That Fits") {
    LabelThatFitsExample()
        .previewSize()
}
