import SwiftUI


public enum TimeSpan {
    case absolute(_ seconds: TimeInterval)
    case relative(_ pointsPerSecond: Double)
}

///  Scrolls view along its desired axis at a looped wait time interval.
public struct ViewLooper<Content: View>: View {
    
    @State private var isStarted = false
    @State private var scrollToCopy = false
    @State private var size: CGSize = .zero
    @State private var activeTask: DispatchWorkItem?
    
    private let axis: Axis
    private let duration: TimeSpan
    private let wait: TimeInterval
    private let featherMask: Bool
    private let content: Content
    
    
    /// Initialize instance
    ///
    /// - Parameters:
    ///   - axis: The axis along which the scrolling happens.
    ///   - duration: How long it takes for the view to scroll. Either absolute which is in seconds or relative which is in pointsPerSecond relative to the views size.  Defaults to relative 30 pointsPerSecond.
    ///   - wait: How long to pause between scrolls. Defaults to 8 seconds.
    ///   - featherMask: Bool indicating whether to feather the mask edges for a feathered scroll clipping. Defaults to true.
    ///   - content: A view builder of the content to scroll.
    public init(
        _ axis: Axis,
        duration: TimeSpan = .relative(30),
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
    
    
    private func tryStart(in size: CGSize) {
        guard isStarted == false, size != .zero else { return }
        isStarted = true
        
        let resolvedDuration: TimeInterval = {
            switch duration {
            case .absolute(let seconds): return seconds
            case .relative(let pointsPerSecond):
                switch axis {
                case .horizontal: return (size.width / 2) / pointsPerSecond
                case .vertical: return (size.height / 2) / pointsPerSecond
                }
            }
        }()
        
        let item = DispatchWorkItem{
            withAnimation(.easeInOut(duration: resolvedDuration)) {
                scrollToCopy.toggle()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + resolvedDuration) {
                scrollToCopy.toggle()
                isStarted = false
            }
        }
        
        activeTask = item
        
        DispatchQueue.main.asyncAfter(deadline: .now() + wait, execute: item)
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
                .fixedSize()
                .boundsReader(readingToSize: $size)
                .drawingGroup()
                .offset(
                    x: axis == .horizontal && scrollToCopy ? -(size.width / 2) : 0,
                    y: axis == .vertical && scrollToCopy ? -(size.height / 2) : 0
                )
                .onChangePolyfill(of: size, initial: true){
                    tryStart(in: size)
                }
                .id("\(axis)_\(isStarted)")
            }
            .mask(maskContent)  
            .onDisappear{
                activeTask?.cancel()
            }
    }
}
