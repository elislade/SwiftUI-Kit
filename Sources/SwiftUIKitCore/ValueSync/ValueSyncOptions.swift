import Foundation


@frozen public struct ValueSyncOptions: OptionSet {
    
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    public static let initialA: ValueSyncOptions = .init(rawValue: 1 << 1)
    public static let initialB: ValueSyncOptions = .init(rawValue: 2 << 1)
    public static let initial: ValueSyncOptions = [.initialA, .initialB]
    
    public static let onChangeA: ValueSyncOptions = .init(rawValue: 3 << 2)
    public static let onChangeB: ValueSyncOptions = .init(rawValue: 4 << 2)
    public static let onChange: ValueSyncOptions = [.onChangeA, .onChangeB]
    
    public static let a: ValueSyncOptions = [.initialA, .onChangeA]
    public static let b: ValueSyncOptions = [.initialB, .onChangeB]
    public static let all: ValueSyncOptions = [.initial, .onChange]
}

