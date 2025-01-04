import SwiftUI


struct ValueSyncModifier<A: PropertyWrapper, B: PropertyWrapper>: ViewModifier where A.Value : Equatable, B.Value : Equatable {
    
    private let options: ValueSyncOptions
    private let mapA: SyncMap<A.Value,B.Value>?
    private let mapB: SyncMap<B.Value,A.Value>?
    
    private let a: A
    private let b: B
    @State private var hasUsedInitialA: Bool = false
    @State private var hasUsedInitialB: Bool = false
    
    init(
        _ a: A, mapA: SyncMap<A.Value,B.Value>?,
        _ b: B, mapB: SyncMap<B.Value,A.Value>?,
        options: ValueSyncOptions = .all
    ){
        self.a = a
        self.b = b
        self.mapA = mapA
        self.mapB = mapB
        self.options = options
    }
    
    private func sync(_ a: A) {
        guard let mapA else { return }
        if let transactionCapable = a as? TransactionCapable {
            withTransaction(transactionCapable.transaction){
                b.wrappedValue = mapA(a.wrappedValue)
            }
        } else {
            b.wrappedValue = mapA(a.wrappedValue)
        }
    }
    
    private func sync(_ b: B) {
        guard let mapB else { return }
        if let transactionCapable = b as? TransactionCapable {
            withTransaction(transactionCapable.transaction){
                a.wrappedValue = mapB(b.wrappedValue)
            }
        } else {
            a.wrappedValue = mapB(b.wrappedValue)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .onChangePolyfill(of: a.wrappedValue, initial: options.contains(.initialA)){
                if hasUsedInitialA == false && options.contains(.initialA) {
                    sync(a)
                    hasUsedInitialA = true
                } else if options.contains(.onChangeA) {
                    sync(a)
                }
            }
            .onChangePolyfill(of: b.wrappedValue, initial: options.contains(.initialB)){
                if hasUsedInitialB == false && options.contains(.initialB) {
                    sync(b)
                    hasUsedInitialB = true
                } else if options.contains(.onChangeB) {
                    sync(b)
                }
            }
    }
    
}


extension ValueSyncModifier where A.Value == B.Value {
    
    init(a: A, b: B, options: ValueSyncOptions = .all){
        self.init(a, mapA: .map{ $0 }, b, mapB: .map{ $0 }, options: options)
    }
    
}
