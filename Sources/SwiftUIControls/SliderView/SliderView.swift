import SwiftUI
import SwiftUIKitCore


/// Allows sliders to be vertical, horizontal, or both at once. If x is set it will be horizontal. if y is set it will be vertical. If both x and y are set the slider will work on both axes at once.
public struct SliderView<Handle: View, Value: BinaryFloatingPoint>: View where Value.Stride : BinaryFloatingPoint {
    
    @Environment(\.layoutDirection) private var layoutDirection
    
    @State private var handleSize: CGSize = .zero
    @State private var hovering = false
    
    let x: SliderState<Value>?
    let y: SliderState<Value>?
    let hitTestHandle: Bool
    let handle: () -> Handle
    
    
    /// Creates a slider with both x and y dimension
    ///
    /// - Parameters:
    ///   - x: A ``SliderState`` representing the value on the x-axis.
    ///   - y: A ``SliderState`` representing the value on the y-axis.
    ///   - hitTestHandle: Bool indicating that handle should be hitTested for gesture. Defaults to true.
    ///   - handle: A view representing the slider handle. Should be smaller in size then actual area of slider.
    public init(
        x: SliderState<Value>? = nil,
        y: SliderState<Value>? = nil,
        hitTestHandle: Bool = true,
        @ViewBuilder handle: @escaping () -> Handle
    ) {
        self.x = x
        self.y = y
        self.hitTestHandle = hitTestHandle
        self.handle = handle
    }
    
    
    /// Creates a slider with only x  dimension
    ///
    /// - Parameters:
    ///   - horizontal: A horizontal ``SliderState`` representing the value on the x-axis.
    ///   - hitTestHandle: Bool indicating that handle should be hitTested for gesture. Defaults to true.
    ///   - handle: A view representing the slider handle. Should be smaller in size then actual area of slider.
    public init(_ horizontal: SliderState<Value>, hitTestHandle: Bool = true, @ViewBuilder handle: @escaping () -> Handle) {
        self.init(x: horizontal, hitTestHandle: hitTestHandle, handle: handle)
    }
    
    
    /// Creates a slider with only y dimension
    ///
    /// - Parameters:
    ///   - vertical: A vertical ``SliderState`` representing the value on the y-axis.
    ///   - hitTestHandle: Bool indicating that handle should be hitTested for gesture. Defaults to true.
    ///   - handle: A view representing the slider handle. Should be smaller in size then actual area of slider.
    public init(vertical: SliderState<Value>, hitTestHandle: Bool = true, @ViewBuilder handle: @escaping () -> Handle) {
        self.init(y: vertical, hitTestHandle: hitTestHandle, handle: handle)
    }
    
    
    /// Calculates handle offset from slider size
    ///
    /// - Parameter size: A `CGSize` representing the available size for the silder.
    ///
    /// - Returns: A `CGSize` representing handle offset.
    private func handleOffset(in size: CGSize) -> CGSize {
        var _x: CGFloat = 0
        var _y: CGFloat = 0
        
        if let x {
            _x = CGFloat(x.percentComplete) * size.width
            _x -= CGFloat(x.percentComplete) * handleSize.width
        }
        
        if let y {
            _y = CGFloat(y.percentComplete) * size.height
            _y -= CGFloat(y.percentComplete) * handleSize.height
        }
        
        return CGSize(width: _x, height: _y)
    }
    
    #if !os(tvOS)
    @State private var space = UUID()
    
    private func gesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(space)).onChanged({ g in
            if let x = x {
                let relativeX = layoutDirection == .leftToRight ? g.location.x : size.width - g.location.x
                let percentX = relativeX / (size.width)
                x.percentComplete = Value(percentX)
            }
            
            if let y = y {
                let percentY = g.location.y / (size.height)
                y.percentComplete = Value(percentY)
            }
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
    ///   - x: A ``SliderState`` representing the value on the x-axis.
    ///   - y: A ``SliderState`` representing the value on the y-axis.
    init(x: SliderState<Value>? = nil, y: SliderState<Value>? = nil) {
        self.init(x: x, y: y, hitTestHandle: false){ EmptyView() }
    }
    
    /// Creates a slider with only x  dimension
    ///
    /// - Parameters:
    ///   - horizontal: A horizontal ``SliderState`` representing the value on the x-axis.
    init(_ horizontal: SliderState<Value>) {
        self.init(x: horizontal, hitTestHandle: false){ EmptyView() }
    }
    
    
    /// Creates a slider with only y dimension
    ///
    /// - Parameters:
    ///   - vertical: A vertical ``SliderState`` representing the value on the y-axis.
    init(vertical: SliderState<Value>) {
        self.init(y: vertical, hitTestHandle: false){ EmptyView() }
    }
    
}
