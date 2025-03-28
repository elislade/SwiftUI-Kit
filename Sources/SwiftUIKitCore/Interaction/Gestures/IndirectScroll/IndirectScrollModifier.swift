import SwiftUI


public struct IndirectScrollGesture: IndirectGesture, Equatable {
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.useMomentum == rhs.useMomentum &&
        lhs.mask == rhs.mask &&
        lhs.maskEvaluation == rhs.maskEvaluation &&
        lhs.onChanges.count == rhs.onChanges.count &&
        lhs.onEnds.count == rhs.onEnds.count
    }
    
    public let useMomentum: Bool
    public let mask: Axis.Set
    public let maskEvaluation: EventMaskEvaluationBehaviour
    
    private var onChanges: [(Value) -> Void]
    private var onEnds: [(Value) -> Void]
    
    public init(
        useMomentum: Bool = true,
        mask: Axis.Set = [.horizontal, .vertical],
        maskEvaluation: EventMaskEvaluationBehaviour = .locked
    ){
        self.useMomentum = useMomentum
        self.mask = mask
        self.maskEvaluation = maskEvaluation
        self.onChanges = []
        self.onEnds = []
    }
    
    public struct Value: Hashable {
        public let time: Double
        public let delta: SIMD2<Double>
    }
    
    public func onChanged(_ action: @escaping (Value) -> Void) -> IndirectScrollGesture {
        var copy = self
        copy.onChanges.append(action)
        return copy
    }
    
    public func onEnded(_ action: @escaping (Value) -> Void) -> IndirectScrollGesture {
        var copy = self
        copy.onEnds.append(action)
        return copy
    }
    
    internal func callChanged(with value: Value){
        for call in onChanges {
            call(value)
        }
    }
    
    internal func callEnded(with value: Value){
        for call in onEnds {
            call(value)
        }
    }
    
}


struct IndirectScrollModifier: ViewModifier {
    
    var gesture: IndirectScrollGesture
    
    func body(content: Content) -> some View {
        #if os(watchOS)
        content
        #else
        IndirectScrollRepresentation(gesture: gesture){
            content
        }
        #endif
    }
    
}
