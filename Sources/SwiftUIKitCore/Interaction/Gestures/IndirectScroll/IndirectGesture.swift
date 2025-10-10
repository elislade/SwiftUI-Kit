
@MainActor @preconcurrency public protocol IndirectGesture {
    
    associatedtype Value
    
    func onChanged(_ action: @MainActor @escaping (Value) -> Void) -> Self
    func onEnded(_ action: @MainActor @escaping (Value) -> Void) -> Self
    
}
