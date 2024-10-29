import SwiftUI


public extension View {
    
    func syncValue<A: PropertyWrapper, B: PropertyWrapper>(_ a: A, _ b: B, options: ValueSyncOptions = .all) -> some View where A.Value : Equatable, B.Value : Equatable, A.Value == B.Value {
        modifier(ValueSyncModifier(a: a, b: b, options: options))
    }
    
    func syncValue<A: PropertyWrapper, B: PropertyWrapper>(
        _ a: A, mapA: SyncMap<A.Value,B.Value>? = nil,
        _ b: B, mapB: SyncMap<B.Value,A.Value>? = nil,
        options: ValueSyncOptions = .all
    ) -> some View where A.Value : Equatable, B.Value : Equatable {
        modifier(ValueSyncModifier(
            a, mapA: mapA,
            b, mapB: mapB,
            options: options
        ))
    }
    
    func syncValue<A: PropertyWrapper, B: PropertyWrapper>(
        _ a: (A, SyncMap<A.Value,B.Value>?),
        _ b: (B, SyncMap<B.Value,A.Value>?),
        options: ValueSyncOptions = .all
    ) -> some View where A.Value : Equatable, B.Value : Equatable {
        modifier(ValueSyncModifier(
            a.0, mapA: a.1,
            b.0, mapB: b.1,
            options: options
        ))
    }
    
    func syncValue<A: PropertyWrapper, B: PropertyWrapper>(
        _ a: A,
        _ b: (B, SyncMap<B.Value,A.Value>?),
        options: ValueSyncOptions = .all
    ) -> some View where A.Value : Equatable, B.Value : Equatable {
        modifier(ValueSyncModifier(
            a, mapA: nil,
            b.0, mapB: b.1,
            options: options
        ))
    }
    
    func syncValue<A: PropertyWrapper, B: PropertyWrapper>(
        _ a: (A, SyncMap<A.Value,B.Value>?),
        _ b: B,
        options: ValueSyncOptions = .all
    ) -> some View where A.Value : Equatable, B.Value : Equatable {
        modifier(ValueSyncModifier(
            a.0, mapA: a.1,
            b, mapB: nil,
            options: options
        ))
    }
    
}


public enum SyncMap<A, B> {
    
    case map((A) -> B)
    case path(KeyPath<A, B>)
    
    public func callAsFunction(_ a: A) -> B {
        switch self {
        case .map(let call): call(a)
        case .path(let path): a[keyPath: path]
        }
    }

}


public protocol PropertyWrapper {
    associatedtype Value
    
    var wrappedValue: Value { get nonmutating set }
}


extension Binding: PropertyWrapper, TransactionCapable {}
extension State: PropertyWrapper {}
extension FocusState: PropertyWrapper {}
extension FocusedBinding: PropertyWrapper {}


public extension PropertyWrapper {
    
    func map<O>(_ map: @escaping (Value) -> O) -> (Self, SyncMap<Value, O>) {
        (self, .map(map))
    }
    
    func map<O>(_ path: KeyPath<Value, O>) -> (Self, SyncMap<Value, O>) {
        (self, .path(path))
    }
    
}


public protocol TransactionCapable {
    
    var transaction: Transaction { get }
    
}
