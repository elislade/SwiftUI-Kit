import SwiftUIKit

struct PointedShapeExamples: View {
    
    @State var anchor: Double = 0.5
    @State var style: RoundedCornerStyle = .continuous
    
    @State var edge: Edge = .bottom
    @State var radius: Double = 16.0
    @State var inset: Double = 0
    @State var type: ShapeType = .roundedRect
    @State var dir: LayoutDirection = .leftToRight
    
    enum ShapeType {
        case circle
        case roundedRect
    }
    
    var body: some View {
        ExampleView(title: "Pointed Shape"){
            Image(systemName: "leaf.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 55)
                .foregroundStyle(.green)
                .padding(44)
                .frame(maxWidth: .infinity)
                .background {
                    switch type {
                    case .circle:
                        PointedCircle(
                            edge: edge
                        )
                        .inset(by: inset)
                        .material(.raised)
                    case .roundedRect:
                        PointedRect(
                            edge: edge,
                            cornerRadius: radius,
                            cornerStyle: style,
                            anchor: anchor
                        )
                        .inset(by: inset)
                        .material(.raised)
                    }
                }
                .geometryGroupIfAvailable()
                .padding(16)
        } parameters : {
            ExampleSection(isExpanded: true) {
                ExampleInlinePicker(
                    data: [.roundedRect, .circle],
                    selection: $type.animation(.bouncy)
                ){ shape in
                    Group {
                        switch shape {
                        case .circle:
                            Label("Circle", systemImage: "circle")
                        case .roundedRect:
                            Label("Rounded Rect", systemImage: "rectangle")
                        }
                    }
                } label: {
                    Text("Type")
                }
                
                HStack {
                    ExampleSlider(
                        value: $inset,
                        in: -25...25,
                        step: 0.5,
                        format: .increment(0.5)
                    ){
                        Text("Inset")
                    }
                    
                    ExampleCell.Edge(edge: $edge)
                        .zIndex(2)
                }
                
                if type == .roundedRect {
                    ExampleInlinePicker(
                        data: [.continuous, .circular],
                        selection: $style.animation(.bouncy)
                    ){ style in
                        Group {
                            switch style {
                            case .continuous: Text("Continuous")
                            case .circular: Text("Circular")
                            default: EmptyView()
                            }
                        }
                    } label: {
                        Text("Corner Style")
                    }
                    
                    HStack {
                        ExampleSlider(
                            value: $radius,
                            in: 0...150,
                            format: .increment(0.1)
                        ){
                            Text("Radius")
                        }
                        
                        ExampleSlider(
                            value: $anchor,
                            in: 0...1,
                            format: .increment(0.1),
                        ){
                            Label("Anchor", systemImage: "scope")
                        }
                        .zIndex(1)
                        .transition(.scale)
                    }
                }
            } label: {
                Text("Parameters")
            }
        }
    }
    
}


#Preview {
    PointedShapeExamples()
        .previewSize()
}
