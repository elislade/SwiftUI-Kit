import SwiftUI


public struct IndirectScrollGesture: IndirectGesture {
    
    public let useMomentum: Bool
    public let mask: Axis.Set
    public let maskEvaluation: EventMaskEvaluationPhase
    
    private let onChange: @MainActor (Value) -> Void
    private let onEnd: @MainActor (Value) -> Void
    
    public init(
        useMomentum: Bool = true,
        mask: Axis.Set = [.horizontal, .vertical],
        maskEvaluation: EventMaskEvaluationPhase = .onBegin
    ){
        self.useMomentum = useMomentum
        self.mask = mask
        self.maskEvaluation = maskEvaluation
        self.onChange = { _ in }
        self.onEnd = { _ in }
    }
    
    internal nonisolated init(
        _ base: IndirectScrollGesture,
        onChange: (@MainActor(Value) -> Void)? = nil,
        onEnd: (@MainActor(Value) -> Void)? = nil
    ){
        self.useMomentum = base.useMomentum
        self.mask = base.mask
        self.maskEvaluation = base.maskEvaluation
        
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
    
    public struct Value: Hashable, Sendable {
        public let time: Double
        public let delta: SIMD2<Double>
        public let translation: SIMD2<Double>
    }
    
    public nonisolated func onChanged(_ action: @MainActor @escaping (Value) -> Void) -> IndirectScrollGesture {
        .init(self, onChange: action)
    }
    
    public nonisolated func onEnded(_ action: @MainActor @escaping (Value) -> Void) -> IndirectScrollGesture {
        .init(self, onEnd: action)
    }
    
    internal func callChanged(with value: Value){
        onChange(value)
    }
    
    internal func callEnded(with value: Value){
        onEnd(value)
    }
    
}


extension IndirectScrollGesture: Equatable {
    
    public nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.useMomentum == rhs.useMomentum &&
        lhs.mask == rhs.mask &&
        lhs.maskEvaluation == rhs.maskEvaluation
    }
    
}


struct IndirectScrollModifier: ViewModifier {
    
    @Environment(\.isBeingPresentedOn) private var isBeingPresentedOn
    
    var gesture: @MainActor () -> IndirectScrollGesture
    
    func body(content: Content) -> some View {
        #if os(watchOS)
        content
        #else
        content.background{
            if !isBeingPresentedOn {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: IndirectGesturePreference.self,
                        value: [ gesture().window(frame: proxy.frame(in: .global)) ]
                    )
                }
            }
        }
        #endif
    }
    
}
