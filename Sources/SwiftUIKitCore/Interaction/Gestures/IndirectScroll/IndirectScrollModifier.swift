import SwiftUI


public struct IndirectScrollGesture: IndirectGesture {
    
    public let axes: Axis.Set
    
    private let invertY: Bool
    private let onChange: @MainActor (Value) -> Void
    private let onEnd: @MainActor (Value) -> Void
    
    public init(axes: Axis.Set = [.horizontal, .vertical]){
        self.axes = axes
        self.onChange = { _ in }
        self.onEnd = { _ in }
        self.invertY = false
    }
    
    internal nonisolated init(
        _ base: IndirectScrollGesture,
        onChange: (@MainActor(Value) -> Void)? = nil,
        onEnd: (@MainActor(Value) -> Void)? = nil
    ){
        self.axes = base.axes
        self.invertY = base.invertY
        
        if let onChange {
            self.onChange = {
                base.onChange($0)
                onChange($0)
            }
        } else {
            self.onChange = base.onChange
        }
        
        if let onEnd {
            self.onEnd = {
                base.onEnd($0)
                onEnd($0)
            }
        } else {
            self.onEnd = base.onEnd
        }
    }
    
    internal nonisolated init(
        _ base: IndirectScrollGesture,
        invertY: Bool
    ){
        self.axes = base.axes
        self.onEnd = base.onEnd
        self.onChange = base.onChange
        self.invertY = invertY
    }
    
    public struct Value: Hashable, Sendable {
        public let time: Date
        public let delta: SIMD2<Double>
        public let translation: SIMD2<Double>
        public let velocity: SIMD2<Double>
        
        public var predictedEndTranslation: SIMD2<Double> {
            let decelerationRate: Double = 0.998
            return translation + ((velocity / 5000) * decelerationRate / (1 - decelerationRate))
        }
        
        func invert(axes: Axis.Set) -> Self {
            guard !axes.isEmpty else { return self }
            return .init(
                time: time,
                delta: delta.invert(axis: axes),
                translation: translation.invert(axis: axes),
                velocity: velocity.invert(axis: axes)
            )
        }
        
        func masked(axes: Axis.Set) -> Self {
            guard !axes.isEmpty else { return self }
            return .init(
                time: time,
                delta: delta.zero(keeping: axes),
                translation: translation.zero(keeping: axes),
                velocity: velocity.zero(keeping: axes)
            )
        }
        
    }
    
    public nonisolated func onChanged(_ action: @MainActor @escaping (Value) -> Void) -> IndirectScrollGesture {
        .init(self, onChange: action)
    }
    
    public nonisolated func onEnded(_ action: @MainActor @escaping (Value) -> Void) -> IndirectScrollGesture {
        .init(self, onEnd: action)
    }
    
    internal func callChanged(with value: Value){
        onChange(value.invert(axes: invertY ? .vertical : []).masked(axes: axes))
    }
    
    internal func callEnded(with value: Value){
        onEnd(value.invert(axes: invertY ? .vertical : []).masked(axes: axes))
    }
    
    internal func invertY(shouldInvert: Bool) -> Self {
        .init(self, invertY: shouldInvert)
    }
    
}


extension IndirectScrollGesture: Equatable {
    
    public nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.axes == rhs.axes &&
        lhs.invertY == rhs.invertY
    }
    
}


struct IndirectScrollModifier: ViewModifier {
    
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.indirectScrollInvertY) private var invertY
    @Environment(\.isBeingPresentedOn) private var isBeingPresentedOn
    
    @State private var changeValue: IndirectScrollGesture.Value? = nil
    @State private var endValue: IndirectScrollGesture.Value? = nil
    @State private var id = UUID()
    
    let gesture: IndirectScrollGesture
    
    func body(content: Content) -> some View {
        #if os(watchOS)
        content
        #else
        content.background{
            if !isBeingPresentedOn {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: IndirectGesturePreference.self,
                        value: [
                            IndirectScrollGesture(axes: gesture.axes)
                                .onChanged{ changeValue = $0 }
                                .onEnded{ endValue = $0 }
                                .invertY(shouldInvert: invertY)
                                .window(id: id, frame: proxy.frame(in: .global))
                        ]
                    )
                }
                .onChangePolyfill(of: endValue){
                    if let endValue {
                        gesture.callEnded(with: endValue)
                    }
                }
                .onChangePolyfill(of: changeValue){
                    if let changeValue {
                        gesture.callChanged(with: changeValue)
                    }
                }
            }
        }
        #endif
    }
    
}
