import Foundation

public protocol IndirectGesture {
    associatedtype Value
    
    func onChanged(_ action: @escaping (Value) -> Void) -> Self
    func onEnded(_ action: @escaping (Value) -> Void) -> Self
}
