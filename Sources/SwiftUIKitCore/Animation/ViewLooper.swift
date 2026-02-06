import SwiftUI


public struct ViewLooper<Content: View>: View {
    
    @Environment(\.frozenState) private var frozenState
    @Environment(\.isBeingPresentedOn) private var isBeingPresentedOn
    
    @State private var size: CGSize = .zero
    
    private let animation: DimensionedAnimationProvider
    private let axis: Axis
    private let spacing: CGFloat
    private let edgeFadeAmount: Double
    private let content: Content
    
    private var disable: Bool {
        isBeingPresentedOn || !frozenState.isThawed
    }
    
    /// Initialize instance
    ///
    /// - Parameters:
    ///   - axis: The axis along which the scrolling happens.
    ///   - spacing: The distance between looped copies. Defaults to 10.
    ///   - animation: An animation provider that is resolved at a specific dimension for the current axis.  Defaults to `.easeInOut(duration: 8).delay(4)`.
    ///   - edgeFadeAmount: Amount in points of how much edge fade there should be for the content. Defaults to 12.
    ///   - content: A view builder of the content to loop.
    public init(
        _ axis: Axis,
        spacing: CGFloat = 10,
        animation: some DimensionedAnimationProvider = Animation.easeInOut(duration: 8).delay(4),
        edgeFadeAmount: Double = 12,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.spacing = spacing
        self.animation = animation
        self.edgeFadeAmount = edgeFadeAmount
        self.content = content()
    }
    
    private var maskContent: some View {
        AxisStack(axis, spacing: 0){
            LinearGradient(
                colors: [.black.opacity(0), .black],
                startPoint: axis == .horizontal ? .leading : .top,
                endPoint: axis == .horizontal ? .trailing : .bottom
            )
            .frame(
                width: axis == .horizontal ? edgeFadeAmount : nil,
                height: axis == .vertical ? edgeFadeAmount : nil
            )
            
            Color.black
            
            LinearGradient(
                colors: [.black, .black.opacity(0)],
                startPoint: axis == .horizontal ? .leading : .top,
                endPoint: axis == .horizontal ? .trailing : .bottom
            )
            .frame(
                width: axis == .horizontal ? edgeFadeAmount : nil,
                height: axis == .vertical ? edgeFadeAmount : nil
            )
        }
        .drawingGroup()
        .environment(\.layoutDirection, .leftToRight)
    }
    
    public var body: some View {
        let offset = (size[axis] + spacing - edgeFadeAmount) / 2
        content
            .hidden()
            .overlay(alignment: .topLeading){
                InnerView(
                    axis: axis,
                    edgeFadeAmount: edgeFadeAmount,
                    spacing: spacing,
                    dimensionSize: offset,
                    animation: animation,
                    content: content
                )
                .disabled(disable)
                .id(axis).id(edgeFadeAmount).id(spacing)
                .onGeometryChangePolyfill(of: \.size){ size = $0 }
            }
            .mask(maskContent)
            .padding(.leading, axis == .horizontal ? -edgeFadeAmount : 0)
            .padding(.top, axis == .vertical ? -edgeFadeAmount : 0)
    }
    
    
    struct InnerView: View {
        
        @Environment(\.isEnabled) private var enabled
        @State private var scrolled = false
        
        let axis: Axis
        let edgeFadeAmount: Double
        let spacing: CGFloat
        let dimensionSize: Double
        let animation: DimensionedAnimationProvider
        let content: Content
        
        var body: some View {
            AxisStack(axis, spacing: spacing) {
                content
                content
            }
            .modifier(SmoothOffset(
                axis: axis,
                offset: scrolled ? -dimensionSize : 0
            ))
            .padding(.leading, axis == .horizontal ? edgeFadeAmount : 0)
            .padding(.top, axis == .vertical ? edgeFadeAmount : 0)
            .fixedSize(horizontal: axis == .horizontal, vertical: axis == .vertical)
            .animation(
                enabled ? animation(dimensionSize).repeatForever(autoreverses: false) : nil,
                value: scrolled
            )
            .onAppear{ scrolled = true }
        }
        
    }
    
    
    struct SmoothOffset: ViewModifier & Animatable {
        
        var axis: Axis
        var offset: Double
        
        nonisolated var animatableData: Double {
            get { offset }
            set { offset = newValue }
        }
        
        func body(content: Self.Content) -> some View {
            content.offset(
                [axis == .horizontal ? offset : 0,
                 axis == .vertical ? offset : 0]
            )
        }
        
    }
    
    
}
