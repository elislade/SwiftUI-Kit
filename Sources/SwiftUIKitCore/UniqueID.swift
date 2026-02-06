import os

/// An ID that is guarenteed to be unique over it's memory lifespan with all other UniqueID's.
/// - Note: This ID is repeatable over different runs as long as instances are retained and released in the exact same order.
public struct UniqueID : Hashable, Sendable {
    
    final private class Heap : @unchecked Sendable {
        
        static let shared = Heap()
        
        struct State {
            var next: Storage.Value = .zero
            var available: Set<Storage.Value> = .init(minimumCapacity: 240)
        }
        
        private var state = OSAllocatedUnfairLock(initialState: State())
        
        func retain() -> Storage.Value {
            state.withLock{
                if let value = $0.available.popFirst() {
                    return value
                } else {
                    let value = $0.next
                    $0.next = value.next()
                    return value
                }
            }
        }
        
        func release(_ value: Storage.Value) {
            state.withLock{
                if value == $0.next.previous() {
                    $0.next = value
                } else {
                    $0.available.insert(value)
                }
            }
        }
        
    }
    
    final private class Storage : @unchecked Sendable {
        
        struct Value: Hashable, Sendable, CustomDebugStringConvertible {
            
            static let zero = Value(minor: 0, intermediate: 0, major: 0)
            
            let minor: UInt8
            let intermediate: UInt8
            let major: UInt8
            
            func next() -> Self {
                if minor < .max {
                    .init(minor: minor + 1, intermediate: intermediate, major: major)
                } else if intermediate < .max {
                    .init(minor: .min, intermediate: intermediate + 1, major: major)
                } else if major < .max {
                    .init(minor: .min, intermediate: .min, major: major + 1)
                } else {
                    fatalError("Overflow")
                }
            }
            
            func previous() -> Self {
                if minor > .min {
                    .init(minor: minor - 1, intermediate: intermediate, major: major)
                } else if intermediate > .min {
                    .init(minor: .max, intermediate: intermediate - 1, major: major)
                } else if major > .min {
                    .init(minor: .max, intermediate: .max, major: major - 1)
                } else {
                    fatalError("Overflow")
                }
            }
            
            var debugDescription: String {
                if major != 0 {
                    "\(major.padded).\(intermediate.padded).\(minor.padded)"
                } else if intermediate != 0 {
                    "\(intermediate.padded).\(minor.padded)"
                } else {
                    minor.padded
                }
            }
            
        }
        
        let value: Value
        
        init() { value = Heap.shared.retain() }
        deinit { Heap.shared.release(value) }
        
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(storage.value)
    }
    
    private let storage: Storage
    
    nonisolated public init(){
        storage = .init()
    }
    
}

extension UniqueID: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.storage.value == rhs.storage.value
    }
    
}

extension UniqueID: CustomDebugStringConvertible {
    
    nonisolated public var debugDescription: String {
        storage.value.debugDescription
    }
    
}


extension UInt8 {
    
    var padded: String {
        let base = String(describing: self)
        let prepend = (0..<(3 - base.count)).map{ _ in Character("0") }
        return String(prepend) + base
    }
    
}
