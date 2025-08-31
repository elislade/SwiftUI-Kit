import SwiftUI


public enum TimeSpan {
    case seconds(Double)
    case millisecondsPerPoint(Double)
}

///  Scrolls view along its desired axis at a looped wait time interval.
public struct ViewLooper<Content: View>: View {
    
    @Environment(\.frozenState) private var frozenState
    @Environment(\.isBeingPresentedOn) private var isBeingPresentedOn
    
    @State private var scrollToCopy = false
    @State private var size: CGSize = .zero
    @State private var count: Int = 0
    
    private let axis: Axis
    private let duration: TimeSpan
    private let wait: TimeInterval
    private let edgeFadeAmount: Double
    private let content: Content
    
    private var startTask: Int {
        var hasher = Hasher()
        hasher.combine(frozenState)
        hasher.combine(isBeingPresentedOn)
        hasher.combine(count)
        return hasher.finalize()
    }
    
    
    /// Initialize instance
    ///
    /// - Parameters:
    ///   - axis: The axis along which the scrolling happens.
    ///   - duration: How long it takes for the view to loop. Either absolute which is in seconds or relative which is in millisecondsPerPoint relative to the views size.  Defaults to 5 millisecondsPerPoint.
    ///   - wait: How long to pause between loopa. Defaults to 8 seconds.
    ///   - edgeFadeAmount: Amount in points of how much edge fade there should be for the content. Defaults to 12.
    ///   - content: A view builder of the content to loop.
    public init(
        _ axis: Axis,
        duration: TimeSpan = .millisecondsPerPoint(5),
        wait: TimeInterval = 8,
        edgeFadeAmount: Double = 12,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.duration = duration
        self.wait = wait
        self.edgeFadeAmount = edgeFadeAmount
        self.content = content()
    }
    
    private func seconds(in size: CGSize) -> Double {
        switch duration {
        case .seconds(let value): return value
        case .millisecondsPerPoint(let value):
            switch axis {
            case .horizontal: return (size.width * value) / 1000
            case .vertical: return (size.height * value) / 1000
            }
        }
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
       content
            .hidden()
            .overlay(alignment: .topLeading){
                AxisStack(axis, spacing: edgeFadeAmount) {
                    content
                    content
                }
                .padding(.leading, axis == .horizontal ? edgeFadeAmount : 0)
                .padding(.top, axis == .vertical ? edgeFadeAmount : 0)
                .fixedSize(horizontal: axis == .horizontal, vertical: axis == .vertical)
                .onGeometryChangePolyfill(of: \.size){ size = $0 }
                .offset(
                    x: axis == .horizontal && scrollToCopy ? -(size.width / 2) : 0,
                    y: axis == .vertical && scrollToCopy ? -(size.height / 2) : 0
                )
                .animation(.easeInOut(duration: seconds(in: size)), value: scrollToCopy)
                .id(count)
            }
            .task(id: startTask, priority: .background){
                guard frozenState.isThawed && !isBeingPresentedOn else { return }
                
                if let _ = try? await Task.sleep(nanoseconds: nanoseconds(seconds: wait)) {
                    scrollToCopy = true
                    if let _ = try? await Task.sleep(nanoseconds: nanoseconds(seconds: seconds(in: size))) {
                        count += 1
                        scrollToCopy = false
                    }
                }
            }
            .mask(maskContent)
            .padding(.leading, axis == .horizontal ? -edgeFadeAmount : 0)
            .padding(.top, axis == .vertical ? -edgeFadeAmount : 0)
    }
    
}
