import SwiftUIKit


public struct BasicExamples: View {
    
    @State private var isPresented = false
    @State private var alignment: Alignment = .center
    
    private var transitions: [AnyTransition] {
        var result: [AnyTransition] = [.opacity, .scale(alignment == .center ? 0 : 1)]

        if let verticalEdge = Edge(alignment.vertical){
            result.append(.moveEdge(verticalEdge))
        }
        
        if let horizontalEdge = Edge(alignment.horizontal){
            result.append(.moveEdge(horizontalEdge))
        }
        
        return result
    }
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Basic Presentation"){
            ZStack {
                Color.clear.contentShape(Rectangle())
                
                Button("Show Presented View"){
                    isPresented.toggle()
                }
                .presentation(isPresented: $isPresented, alignment: alignment){
                    PresentedView()
                        .frame(maxWidth: 300)
                        .padding()
                        .transition(
                            .merge(transitions).animation(.bouncy(extraBounce: 0.1))
                        )
                        .geometryGroupIfAvailable()
                        .presentationBackdrop(.changedPassthrough){
                            Color.black.opacity(0.7)
                        }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .presentationContext()
        } parameters: {
            Toggle(isOn: $isPresented){
                Text("Is Presented")
            }

            ExampleCell.Alignment(value: $alignment)
        }
    }
    
    
    struct PresentedView: View {
        
        @Environment(\.dismissPresentation) private var dismiss
        
        var body: some View {
            VStack(spacing: 10) {
                HStack(spacing: 12){
                    Text("Presented View")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button{ dismiss() } label: {
                        Label{ Text("Close") } icon: {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                    .buttonStyle(.tinted)
                    .labelStyle(.iconOnly)
                }
                .font(.title[.bold])
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .symbolRenderingMode(.hierarchical)
                .padding(.leading, 6)
  
                ContainerRelativeShape()
                    .fill(.tint)
                    .aspectRatio(2, contentMode: .fit)
            }
            .padding(10)
            .background{
                ContainerRelativeShape()
                    .fill(.regularMaterial)
            }
            .containerShape(RoundedRectangle(cornerRadius: 24))
        }
    }
    
}


#Preview("Basic Presentation") {
    BasicExamples()
        .previewSize()
}
