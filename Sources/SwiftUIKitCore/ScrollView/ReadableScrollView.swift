import SwiftUI


/// A SwiftUI ScrollView that you can read its content offset and content size
public struct ReadableScrollView<Content: View>: View {
    
    @Environment(\.scrollOffsetPassthrough) private var offsetPassthrough
    
    @State private var handlesReset: Bool = false
    @State private var isResetting = false
    @State private var scrollOrigin: CGPoint = .zero
    
    let axis: Axis.Set
    let showsIndicators: Bool
    private let contentOffset: (CGPoint) -> Void
    private let contentSize: (CGSize) -> Void
    private let content: Content
    private let resetScrollThreshold: Double = 300
    
    /// Creates an instance of `ReadableScrollView`
    ///
    /// - Parameters:
    ///   - axis: The scroll view's scrollable axis. The default axis is the vertical axis.
    ///   - showsIndicators: A Boolean value that indicates whether the scroll view displays the scrollable component of the content offset, in a way suitable for the platform.
    ///   The default value for this parameter is `true`.
    ///   - contentOffset: Callback of a `CGPoint` indicating the content offset. Defaults to empty closure.
    ///   - contentSize: Callback of a `CGSize` indicating the content size. Defaults to empty closure.
    ///   - content: The view builder that builds the content to scroll.
    public init(
        _ axis: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        contentOffset: @escaping (CGPoint) -> Void = { _ in },
        contentSize: @escaping (CGSize) -> Void = { _ in },
        @ViewBuilder content: @escaping () -> Content
    ){
        self.axis = axis
        self.showsIndicators = showsIndicators
        self.contentOffset = contentOffset
        self.contentSize = contentSize
        self.content = content()
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(axis, showsIndicators: showsIndicators) {
                content
                    .id("ScrollContent")
                    .onGeometryChangePolyfill(of: { $0.frame(in: .global).origin.rounded(.towardZero) }){
                        let origin = $0
                        let offset = CGPoint(x: origin.x - scrollOrigin.x, y: origin.y - scrollOrigin.y)
                        offsetPassthrough?.send(offset)
                        contentOffset(offset)
                        handlesReset = {
                            let xPass = axis.contains(.horizontal) ? offset.x < -resetScrollThreshold : false
                            let yPass = axis.contains(.vertical) ? offset.y < -resetScrollThreshold : false
                            return yPass || xPass
                        }()
                    }
                    .onGeometryChangePolyfill(of: { $0.size.rounded(.towardZero) }){
                        contentSize($0)
                    }
            }
            .onGeometryChangePolyfill(of: { $0.frame(in: .global).origin.rounded(.towardZero) }){
                scrollOrigin = $0
            }
            .resetAction(active: handlesReset && !isResetting){
                isResetting = true
                withAnimation(.smooth){
                    proxy.scrollTo("ScrollContent", anchor: axis == .vertical ? .top : .leading)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    isResetting = false
                }
            }
        }
        .stickyContext()
    }
    
}
