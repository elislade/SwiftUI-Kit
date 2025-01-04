import SwiftUI


public struct IndirectScrollGesture: IndirectGesture {
    
    public let useMomentum: Bool
    private var onChanges: [(Value) -> Void]
    private var onEnds: [(Value) -> Void]
    
    public init(useMomentum: Bool = true){
        self.useMomentum = useMomentum
        self.onChanges = []
        self.onEnds = []
    }
    
    public struct Value: Hashable {
        public let time: Double
        public let deltaX: Double
        public let deltaY: Double
        
        public var delta: SIMD2<Double> {
            .init(deltaX, deltaY)
        }
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
        IndirectScrollRepresentation(gesture: gesture){
            content
        }
    }
    
}
