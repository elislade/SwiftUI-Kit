import SwiftUI
import SwiftUIKitCore


/// A Slider that can be vertical, horizontal, or both at once. If x is set it will be horizontal. if y is set it will be vertical. If both x and y are set the slider will work on both axes at once.
public struct SliderView<Handle: View, Value: BinaryFloatingPoint>: View where Value.Stride : BinaryFloatingPoint {
    
    @Environment(\.layoutDirection) private var layoutDirection
    
    @State private var handleSize: CGSize = .zero
    @State private var hovering = false
    
    @State private var startDrag: CGPoint?
    
    @Binding private var x: Clamped<Value>
    @Binding private var y: Clamped<Value>
    
    let activeAxis: Axis.Set
    let hitTestHandle: Bool
    let handle: () -> Handle
    
    
    /// Creates a slider with both x and y dimension
    ///
    /// - Parameters:
    ///   - x: A clamped value representing the x-axis.
    ///   - y: A clamped value representing the y-axis.
    ///   - hitTestHandle: Bool indicating that handle should be hitTested for gesture. Defaults to true.
    ///   - handle: A view representing the slider handle. Should be smaller in size then actual area of slider.
    public init(
        x: Binding<Clamped<Value>>,
        y: Binding<Clamped<Value>>,
        hitTestHandle: Bool = true,
        @ViewBuilder handle: @escaping () -> Handle
    ) {
        self._x = x
        self._y = y
        self.activeAxis = [.horizontal, .vertical]
        self.hitTestHandle = hitTestHandle
        self.handle = handle
    }
    
    
    /// Creates a slider with only x  dimension
    ///
    /// - Parameters:
    ///   - x: A clamped value representing the x-axis.
    ///   - hitTestHandle: Bool indicating that handle should be hitTested for gesture. Defaults to true.
    ///   - handle: A view representing the slider handle. Should be smaller in size then actual area of slider.
    public init(x: Binding<Clamped<Value>>, hitTestHandle: Bool = true, @ViewBuilder handle: @escaping () -> Handle) {
        self._x = x
        self._y = x
        self.activeAxis = .horizontal
        self.handle = handle
        self.hitTestHandle = hitTestHandle
    }
    
    
    /// Creates a slider with only y dimension
    ///
    /// - Parameters:
    ///   - y: A clamped value representing the y-axis.
    ///   - hitTestHandle: Bool indicating that handle should be hitTested for gesture. Defaults to true.
    ///   - handle: A view representing the slider handle. Should be smaller in size then actual area of slider.
    public init(y: Binding<Clamped<Value>>, hitTestHandle: Bool = true, @ViewBuilder handle: @escaping () -> Handle) {
        self._x = y
        self._y = y
        self.activeAxis = .vertical
        self.handle = handle
        self.hitTestHandle = hitTestHandle
    }
    
    
    /// Calculates handle offset from slider size
    ///
    /// - Parameter size: A `CGSize` representing the available size for the silder.
    ///
    /// - Returns: A `CGSize` representing handle offset.
    private func handleOffset(in size: CGSize) -> CGSize {
        var _x: CGFloat = 0
        var _y: CGFloat = 0
        
        if activeAxis.contains(.horizontal) {
            _x = CGFloat(x.percentComplete) * size.width
            _x -= CGFloat(x.percentComplete) * handleSize.width
        }
        
        if activeAxis.contains(.vertical) {
            _y = CGFloat(y.percentComplete) * size.height
            _y -= CGFloat(y.percentComplete) * handleSize.height
        }
        
        return CGSize(width: _x, height: _y)
    }
    
    #if !os(tvOS)
    @State private var space = UUID()
    
    private func dragValue(_ translation: CGPoint, in size: CGSize) {
        if activeAxis.contains(.horizontal) {
            let relativeX = layoutDirection == .leftToRight ? translation.x : size.width - translation.x
            let percentX = relativeX / (size.width)
            x.percentComplete = Value(percentX)
        }
        
        if activeAxis.contains(.vertical) {
            let percentY = translation.y / (size.height)
            y.percentComplete = Value(percentY)
        }
    }
    
    private func gesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(space)).onChanged({ g in
            dragValue(g.location, in: size)
        })
    }
    #endif
    
    public var body: some View {
        Color.clear.overlay{
            GeometryReader { proxy in
                ZStack(alignment: .topLeading) {
                    handle()
                        .hoverEffectPolyfill()
                        .onGeometryChangePolyfill(of: { $0.size }){ handleSize = $0 }
                        .offset(handleOffset(in: proxy.size))
                        #if !os(tvOS)
                        .gesture(hitTestHandle ? gesture(in: proxy.size) : nil)
                        #endif
                    
                    if hitTestHandle == false {
                        Color.clear
                            .contentShape(Rectangle())
                            #if !os(tvOS)
                            .gesture(
                                LongPressGesture(minimumDuration: 0.08, maximumDistance: 6)
                                    .sequenced(before: gesture(in: proxy.size))
                            )
                            #endif
                    }
                }
            }
        }
        #if !os(tvOS)
        .coordinateSpace(name: space)
        #endif
    }
}


public extension SliderView where Handle == EmptyView {
    
    /// Creates a slider with both x and y dimension
    ///
    /// - Parameters:
    ///   - x: A clamped value representing the x-axis.
    ///   - y: A clamped value representing the y-axis.
    init(x: Binding<Clamped<Value>>, y: Binding<Clamped<Value>>) {
        self.init(x: x, y: y, hitTestHandle: false){ EmptyView() }
    }
    
    /// Creates a slider with only x  dimension
    ///
    /// - Parameters:
    ///   - x: A clamped value representing the x-axis.
    init(x: Binding<Clamped<Value>>) {
        self.init(x: x, hitTestHandle: false){ EmptyView() }
    }
    
    
    /// Creates a slider with only y dimension
    ///
    /// - Parameters:
    ///   - y: A clamped value representing the y-axis.
    init(y: Binding<Clamped<Value>>) {
        self.init(y: y, hitTestHandle: false){ EmptyView() }
    }
    
}
