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
        Button(action: { isPresented = true }){
            RoundedRectangle(cornerRadius: 20)
                .fill(sourceTint)
                .frame(width: 60, height: 60)
        }
        .buttonStyle(.plain)
        .environment(\.layoutDirection, direction)
    }
    
    public var body: some View {
        ExampleView(
            title: "Anchor Presentation"//,
            //maxSize: .init(width: CGFloat.infinity, height: 500)
        ){
            ZStack {
                Color.clear
                
                if useAutoAnchored {
                    sourceView.autoAnchorPresentation(isPresented: $isPresented){ state in
                        PresentedView()
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
                            .tint(presentedTint)
                    }
                    .offset(sourceLocation)
                }
            }
            .anchorPresentationContext(environmentBehaviour: .usePresentation)
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
        
        var title = "Presented View"
        
        var body: some View {
            VStack{
                HStack {
                    Text(title)
                        .font(.title2.weight(.bold))
                    
                    Spacer()
                    
                    Button(action: { dismissPresentation() }){
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                    }
                    .buttonStyle(.plain)
                }
                
                Color.white
                    .opacity(0.5)
                    .clipShape(ContainerRelativeShape())
            }
            .symbolRenderingMode(.hierarchical)
            .padding()
            .foregroundStyle(.white)
            .background{
                Rectangle()
                    .fill(.tint)
            }
            .clipShape(ContainerRelativeShape())
            .containerShape(RoundedRectangle(cornerRadius: 22))
            .frame(width: 200, height: 240)
        }
        
    }
    
    
}


#Preview("Anchor Presentation") {
    AnchorPresentationExample()
        .previewSize()
}
