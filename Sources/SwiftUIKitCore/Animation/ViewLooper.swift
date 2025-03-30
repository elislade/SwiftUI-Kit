import SwiftUI


public enum TimeSpan {
    case seconds(Double)
    case millisecondsPerPoint(Double)
}

///  Scrolls view along its desired axis at a looped wait time interval.
public struct ViewLooper<Content: View>: View {
    
    @State private var scrollToCopy = false
    @State private var size: CGSize = .zero
    @State private var count: Int = 0
    
    private let axis: Axis
    private let duration: TimeSpan
    private let wait: TimeInterval
    private let featherMask: Bool
    private let content: Content
    
    
    /// Initialize instance
    ///
    /// - Parameters:
    ///   - axis: The axis along which the scrolling happens.
    ///   - duration: How long it takes for the view to scroll. Either absolute which is in seconds or relative which is in millisecondsPerPoint relative to the views size.  Defaults to 5 millisecondsPerPoint.
    ///   - wait: How long to pause between scrolls. Defaults to 8 seconds.
    ///   - featherMask: Bool indicating whether to feather the mask edges for a feathered scroll clipping. Defaults to true.
    ///   - content: A view builder of the content to scroll.
    public init(
        _ axis: Axis,
        duration: TimeSpan = .millisecondsPerPoint(5),
        wait: TimeInterval = 8,
        featherMask: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.duration = duration
        self.wait = wait
        self.featherMask = featherMask
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
                colors: [.black.opacity(featherMask ? 0 : 1), .black],
                startPoint: axis == .horizontal ? .leading : .top,
                endPoint: axis == .horizontal ? .trailing : .bottom
            )
            .frame(
                width: axis == .horizontal ? 12 : nil,
                height: axis == .vertical ? 12 : nil
            )
            
            Color.black
            
            LinearGradient(
                colors: [.black, .black.opacity(featherMask ? 0 : 1)],
                startPoint: axis == .horizontal ? .leading : .top,
                endPoint: axis == .horizontal ? .trailing : .bottom
            )
            .frame(
                width: axis == .horizontal ? 12 : nil,
                height: axis == .vertical ? 12 : nil
            )
        }
        .drawingGroup()
        .environment(\.layoutDirection, .leftToRight)
    }
    
    public var body: some View {
       content
            .hidden()
            .overlay(alignment: .topLeading){
                AxisStack(axis, spacing: 0) {
                    content
                    content
                }
                .fixedSize(horizontal: axis == .horizontal, vertical: axis == .vertical)
                .onGeometryChangePolyfill(of: \.size){ size = $0 }
                .offset(
                    x: axis == .horizontal && scrollToCopy ? -(size.width / 2) : 0,
                    y: axis == .vertical && scrollToCopy ? -(size.height / 2) : 0
                )
                .animation(.easeInOut(duration: seconds(in: size)), value: scrollToCopy)
                .id(count)
            }
            .task(id: count){
                let waitNano = UInt64(Double(NSEC_PER_SEC) * wait)
                if let _ = try? await Task.sleep(nanoseconds: waitNano) {
                    scrollToCopy = true
                    let durationNano = UInt64(Double(NSEC_PER_SEC) * seconds(in: size))
                    if let _ = try? await Task.sleep(nanoseconds: durationNano) {
                        count += 1
                        scrollToCopy = false
                    }
                }
            }
            .clipped()
            .mask(maskContent)
    }
    
}
