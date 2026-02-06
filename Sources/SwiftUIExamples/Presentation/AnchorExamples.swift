import SwiftUIKit


public struct AnchorPresentationExample : View   {
    
    enum AnchorType: CaseIterable {
        case horizontal
        case explicit
        case vertical
    }
    
    private var mappedType: PresentedAnchorType {
        switch type {
        case .explicit: .explicit(
            source: sourceAnchor,
            destination: presentationAnchor
        )
        case .horizontal: .horizontal(preferredAlignment: verticalAlign)
        case .vertical: .vertical(preferredAlignment: horizontalAlign)
        }
    }
    
    @State private var type: AnchorType = .horizontal
    @State private var direction: LayoutDirection = .leftToRight
    @State private var sourceAnchor: UnitPoint = .center
    @State private var presentationAnchor: UnitPoint = .center
    
    @State private var sourceLocationLast: CGSize = .zero
    @State private var sourceLocation: CGSize = .zero
    
    @State private var horizontalAlign: HorizontalAlignment = .trailing
    @State private var verticalAlign: VerticalAlignment = .top
    
    @State private var isPresented = false
    
    public init() {}
    
    
    public var body: some View {
        ExampleView(title: "Anchor Presentation"){
            VStack(spacing: 0) {
                Color.clear.overlay {
                    Button{ isPresented = true } label: {
                        Text("S")
                            .foregroundStyle(.white)
                            .padding()
                            .background{
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.tint)
                            }
                    }
                    .geometryGroupIfAvailable()
                    .buttonStyle(.plain)
                    .disabled(isPresented)
                    .anchorPresentation(
                        isPresented: $isPresented,
                        type: mappedType
                    ){
                        PresentedView()
                            .anchorLayoutPadding(10)
                            .transition(
                                (.scale([0.8, 0.8], anchor: .topLeading) + .opacity)
                                    .animation(.bouncy)
                            )
                            .presentationBackdrop(.disabled){
                                Color.clear
                            }
                    }
                    .offset(sourceLocation)
                }
#if !os(tvOS)
                .contentShape(Rectangle())
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
            }
            .safeAreaInset(edge: .top, spacing: 0){
                HStack(
                    alignment: .center,
                    spacing: -5
                ) {
                    RootMenuItem{ Image(systemName: "apple.logo") }
                    RootMenuItem{ Text("SwiftUI Kit") }
                        .fontWeight(.bold)
                    
                    RootMenuItem{ Text("File") }
                    RootMenuItem{ Text("Edit") }
                    RootMenuItem{ Text("View") }
                    
                    Spacer(minLength: 0)
                }
                .fontWeight(.medium)
                .padding(.horizontal, 5)
                .environment(\.layoutDirection, direction)
            }
            .environment(\.layoutDirection, direction)
            .presentationContext()
            .presentationEnvironmentBehaviour(.usePresentation)
        } parameters: {
            Toggle(isOn: $isPresented){
                Text("Is Presented")
                    .font(.exampleParameterTitle)
            }
            .exampleParameterCell()
            
            ExampleCell.LayoutDirection(
                value: $direction.animation(.smooth)
            )
            
            SegmentedPicker(
                selection: $type.animation(.bouncy),
                items: AnchorType.allCases
            ){
                TypeLabel($0)
                    .font(.caption[.monospaced])
                    .opacity(0.5)
            }
            .exampleParameterCell()
            
            Group {
                switch type {
                case .explicit:
                    HStack(spacing: 16) {
                        AnchorView(
                            title: Text("Source"),
                            anchor: $sourceAnchor
                        )

                        AnchorView(
                            title: Text("Destination"),
                            anchor: $presentationAnchor
                        )
                    }
                    .padding()
                    .frame(maxHeight: 200)
                case .horizontal:
                    ExampleCell.Alignment.Vertical(
                        value: $verticalAlign.animation(.bouncy)
                    )
                case .vertical:
                    ExampleCell.Alignment.Horizontal(
                        value: $horizontalAlign.animation(.bouncy)
                    )
                }
            }
            .transition(.scale(0.8) + .opacity)
        }
    }
        
    
    struct TypeLabel: View {
        
        let type: AnchorType
        
        init(_ type: AnchorType) {
            self.type = type
        }
        
        var body: some View {
            switch type {
            case .explicit: Text("Explicit")
            case .horizontal: Text("Horizontal")
            case .vertical: Text("Vertical")
            }
        }
    }
    
    
    struct RootMenuItem<Content: View>: View {
        
        @State private var isPresented = false
        @ViewBuilder var content: Content
        
        var body: some View {
            Button{ isPresented.toggle() } label: {
                content
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background{
                        RoundedRectangle(cornerRadius: 6)
                            .opacity(isPresented ? 0.2 : 0)
                    }
            }
            .buttonStyle(.tinted)
            .geometryGroupIfAvailable()
            .lineLimit(1)
            .anchorPresentation(
                isPresented: $isPresented,
                type: .vertical(preferredAlignment: .leading)
            ){
                PresentedView()
                    .transition(
                        (.scale([0.5, 0.5], anchor: .topLeading) + .opacity)
                            .animation(.bouncy.speed(1.6))
                    )
                    .presentationBackdrop(.disabled){
                        Color.clear
                    }
            }
        }
        
    }
    
    
    struct AnchorView: View {
        
        let title: Text
        @Binding var anchor: UnitPoint
        
        var body: some View {
            ExampleControl.Anchor(value: $anchor)
                .overlay(alignment: .top) {
                    title
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                        .padding(10)
                        .background{
                            LinearGradient(
                                colors: [.secondary, .secondary.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .colorInvert()
                            .clipShape(UnevenRoundedRectangle(
                                topLeadingRadius: 20,
                                topTrailingRadius: 20).inset(by: 1)
                            )
                            .allowsHitTesting(false)
                        }
                }
            .animation(.fastSpringInteractive, value: anchor)
            .symbolVariant(.circle.fill)
            .symbolRenderingMode(.hierarchical)
        }
        
    }
    
    
    struct PresentedView: View {
        
        @Environment(\.dismissPresentation) private var dismissPresentation
        
        struct Item: View {
            
            @State private var isPresented = false
            @State private var isHovering = false
            
            var body: some View {
                Button{ isPresented = true } label: {
                    HStack(spacing: 0) {
                        Text("Item")
                        
                        Spacer(minLength: 12)
                        
                        Image(systemName: "chevron.right")
                            .fontWeight(.bold)
                            .imageScale(.small)
                            .layoutDirectionMirror()
                    }
                    .padding(6)
                    .frame(width: 150)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.none)
                .disabled(isPresented)
                .background {
                    if isHovering && !isPresented {
                        Color.clear.task{
                            if let _ = try? await Task.sleep(for: .seconds(0.3)){
                                isPresented = true
                            }
                        }
                    }
                }
                .onInteractionHover{ phase in
                    isHovering = phase == .entered
                }
                .anchorPresentation(
                    isPresented: $isPresented,
                    type: .horizontal(preferredAlignment: .top),
                    isLeader: true
                ){
                    PresentedView()
                        .transition(
                            (.scale([0.8, 0.8], anchor: .topLeading) + .opacity)
                                .animation(.bouncy)
                        )
                }
                .foregroundStyle(isHovering ? .white : .primary)
                .background{
                    if isHovering {
                        ContainerRelativeShape()
                            .fill(.tint)
                    } else if isPresented {
                        ContainerRelativeShape()
                            .opacity(0.1)
                    }
                }
                .padding(5)
                .onHover{ hovering in
                    isHovering = hovering
                }
            }
            
        }
        
        var body: some View {
            VStack(spacing: 0){
                HStack(alignment: .top) {
                    Text("Menu")
                    
                    Spacer()
                    
                    Button{ dismissPresentation() } label: {
                        Label{ Text("Dismiss") } icon: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                }
                .font(.headline[.bold])
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                
                Divider()
                
                VStack(spacing: -10) {
                    Item()
                    Item()
                    
                    Divider()
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                    
                    Item()
                }
                .interactionHoverGroup(priority: .window)
            }
            .symbolRenderingMode(.hierarchical)
            .background{
                ContainerRelativeShape()
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 6)
                
                ContainerRelativeShape()
                    .inset(by: -0.5)
                    .strokeBorder(.black, lineWidth: 0.5)
                    .opacity(0.5)
                
                ContainerRelativeShape()
                    .inset(by: 0.5)
                    .strokeBorder(.white, lineWidth: 0.5)
                    .opacity(0.2)
            }
            .containerShape(RoundedRectangle(cornerRadius: 12))
            .geometryGroupIfAvailable()
        }
        
    }
    
    
}


#Preview("Anchor Presentation") {
    AnchorPresentationExample()
        .previewSize()
}
