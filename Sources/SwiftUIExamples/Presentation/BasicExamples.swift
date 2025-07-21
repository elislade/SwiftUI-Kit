import SwiftUIKit


public struct BasicExamples: View {
    
    @State private var isPresented = false
    @State private var anchor: UnitPoint = .bottom
    
    private var alignment: Alignment { .init(anchor) }
    
    private var transitions: [AnyTransition] {
        var result: [AnyTransition] = [.opacity, .scale(anchor == .center ? 0 : 1)]
        
        if let verticalEdge = Edge(alignment.vertical){
            result.append(.move(edge: verticalEdge))
        }
        
        if let horizontalEdge = Edge(alignment.horizontal){
            result.append(.move(edge: horizontalEdge))
        }
        
        return result
    }
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Basic Presentation"){
            Button("Show Presented View"){
                isPresented.toggle()
            }
            .presentation(isPresented: $isPresented, alignment: alignment){
                PresentedView()
                    .frame(maxWidth: 300)
                    .padding()
                    .transition(.merge(transitions))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .presentationContext()
        } parameters: {
            Toggle(isOn: $isPresented){
                Text("Is Presented")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()

            HStack {
                Text("Vertical Alignment")
                    .fixedSize(horizontal: true, vertical: false)
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $anchor){
                    Text("Top").tag(UnitPoint(x: anchor.x, y: 0))
                    Text("Center").tag(UnitPoint(x: anchor.x, y: 0.5))
                    Text("Bottom").tag(UnitPoint(x: anchor.x, y: 1))
                }
            }
            .exampleParameterCell()
            
            HStack {
                Text("Horizontal Alignment")
                    .fixedSize(horizontal: true, vertical: false)
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $anchor){
                    Text("Leading").tag(UnitPoint(x: 0, y: anchor.y))
                    Text("Center").tag(UnitPoint(x: 0.5, y: anchor.y))
                    Text("Trailing").tag(UnitPoint(x: 1, y: anchor.y))
                }
            }
            .exampleParameterCell()
        }
    }
    
    
    struct PresentedView: View {
        
        @Environment(\.dismissPresentation) private var dismissPresentation
        
        var body: some View {
            VStack(spacing: 16) {
                HStack{
                    Text("Presented View")
                        .font(.title2.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    
                    Spacer(minLength: 12)
                    
                    Button(action: { dismissPresentation() }){
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                    }
                    .buttonStyle(.tinted)
                }
                .symbolRenderingMode(.hierarchical)
  
                Color.random
                    .aspectRatio(2, contentMode: .fit)
                    .clipShape(ContainerRelativeShape())
            }
            .padding()
            .background{
                ContainerRelativeShape()
                    .fill(.background)
                    .ignoresSafeArea()
            }
            .containerShape(RoundedRectangle(cornerRadius: 28))
        }
    }
    
}


#Preview("Basic Presentation") {
    BasicExamples()
        .previewSize()
}
