import SwiftUIKit


public struct AnchorPresentationExample : View   {
    
    @State private var direction: LayoutDirection = .leftToRight
    @State private var sourceAnchor: UnitPoint = .center
    @State private var presentationAnchor: UnitPoint = .center
    
    @State private var sourceLocationLast: CGSize = .zero
    @State private var sourceLocation: CGSize = .zero
    
    @State private var isPresented = false
    @State private var useAutoAnchored = false
    
    private let sourceTint = Color.blue
    private let presentedTint = Color.pink
    
    public init() {}
    
    private var sourceView: some View {
        Button{ isPresented = true } label: {
            Text("Source")
                .foregroundStyle(.white)
                .frame(width: 80, height: 50)
                .background{
                    RoundedRectangle(cornerRadius: 16)
                        .fill(sourceTint)
                }
        }
        .buttonStyle(.plain)
    }
    
    public var body: some View {
        ExampleView(title: "Anchor Presentation"){
            ZStack {
                Color.clear
                
                if useAutoAnchored {
                    sourceView.anchorPresentation(isPresented: $isPresented){ state in
                        PresentedView()
                            .frame(width: 200, height: 200)
                            .tint(presentedTint)
                            .padding(.init(state.edge))
                    }
                    .offset(sourceLocation)
                } else {
                    sourceView.anchorPresentation(
                        isPresented: $isPresented,
                        sourceAnchor: sourceAnchor,
                        presentationAnchor: presentationAnchor
                    ){
                        PresentedView()
                            .frame(width: 200, height: 200)
                            .tint(presentedTint)
                    }
                    .offset(sourceLocation)
                }
            }
            .anchorPresentationContext()
            .presentationEnvironmentBehaviour(.usePresentation)
            #if !os(tvOS)
            .simultaneousGesture(
                DragGesture().onChanged{ g in
                    if sourceLocation == .zero {
                        sourceLocation = sourceLocationLast
                    }
                    let layoutNormalize = direction == .leftToRight ? 1.0 : -1.0
                    sourceLocation = .init(
                        width: sourceLocationLast.width + g.translation.width * layoutNormalize,
                        height: sourceLocationLast.height + g.translation.height
                    )
                }.onEnded { _ in
                    sourceLocationLast = sourceLocation
                }
            )
            #endif
            .environment(\.layoutDirection, direction)
            .clipped()
        } parameters: {
            Toggle(isOn: $isPresented){
                Text("Is Presented")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            Toggle(isOn: $useAutoAnchored){
                Text("Auto Anchor")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            HStack {
                AnchorView(title: Text("Source Anchor"), anchor: $sourceAnchor)
                    .tint(sourceTint)
                    .disabled(useAutoAnchored)
                
                Divider()
                
                AnchorView(title: Text("Presentation Anchor"), anchor: $presentationAnchor)
                    .tint(presentedTint)
                    .disabled(useAutoAnchored)
            }
            
            Divider()
            
            ExampleCell.LayoutDirection(value: $direction)
            
        }
    }
        
        
    struct AnchorView: View {
        
        let title: Text
        @Binding var anchor: UnitPoint
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10){
                title
                    .font(.exampleParameterTitle)
                    .frame(maxWidth: 130, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                
                ExampleControl.Anchor(value: $anchor)
                    .frame(height: 110)
            }
            .animation(.fastSpringInteractive, value: anchor)
            .symbolVariant(.circle.fill)
            .symbolRenderingMode(.hierarchical)
            .padding()
        }
        
    }
    
    
    struct PresentedView: View {
        
        @Environment(\.dismissPresentation) private var dismissPresentation
        
        var body: some View {
            VStack{
                HStack(alignment: .top) {
                    Text("Presented")
                        .font(.title2.weight(.bold))
                    
                    Spacer()
                    
                    Button{ dismissPresentation() } label: {
                        Label{ Text("Dismiss") } icon: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24)
                        }
                        .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                }
                
                ContainerRelativeShape()
                    .fill(.white.opacity(0.3))
            }
            .symbolRenderingMode(.hierarchical)
            .padding()
            .foregroundStyle(.white)
            .background{
                ContainerRelativeShape()
                    .fill(.tint)
            }
            .containerShape(RoundedRectangle(cornerRadius: 22))
            .transition(.scale(0.8) + .opacity)
        }
        
    }
    
    
}


#Preview("Anchor Presentation") {
    AnchorPresentationExample()
        .previewSize()
}
