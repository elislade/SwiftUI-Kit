import SwiftUI


public struct CachedShape<Base: Shape> : Shape, @unchecked Sendable {
    
    let base: Base
    let isActive: Bool
    let id: AnyHashable
    
    private let lifecycle = Lifecycle()
    
    public init<ID: Hashable>(_ base: Base, isActive: Bool, id: ID) {
        self.base = base
        self.isActive = isActive
        self.id = id
    }
    
    private func key(for size: CGSize) -> Int {
        var hasher = Hasher()
        hasher.combine(ObjectIdentifier(Base.self))
        hasher.combine(id)
        hasher.combine(size.width)
        hasher.combine(size.height)
        return hasher.finalize()
    }
    
    private func getStorage(in size: ProposedViewSize) -> PathCacheStorage.Element {
        let defaultSize = CGSize(
            width: Double.greatestFiniteMagnitude,
            height: Double.greatestFiniteMagnitude
        )
        let staticSize = size.replacingUnspecifiedDimensions(by: defaultSize)
        let cache = PathCacheStorage.shared
        let key = key(for: staticSize)
        lifecycle.key = key
        
        guard isActive else {
            let sizeThatFits = base.sizeThatFits(size)
            let path = base.path(in: CGRect(origin: .zero, size: sizeThatFits))
            cache[key]?.wasActive = false
            return .init(path: path, sizeThatFits: sizeThatFits)
        }
        
        if let cached = cache[key], cached.wasActive {
            return cached
        }
        
        let sizeThatFits = base.sizeThatFits(size)
        let path = PathCacheStorage.Element(
            path: base.path(in: CGRect(origin: .zero, size: sizeThatFits)),
            sizeThatFits: sizeThatFits
        )
        
        cache[key] = path
        return path
    }
    
    public func path(in rect: CGRect) -> Path {
        getStorage(in: .init(rect.size)).path
    }
    
    public func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        getStorage(in: proposal).sizeThatFits
    }
    
    
    final class Lifecycle : @unchecked Sendable {
        
        var key: Int = 0
        
        deinit {
            PathCacheStorage.shared[key] = nil
        }
    }
    
}


extension CachedShape : InsettableShape where Base : InsettableShape {
    
    public nonisolated func inset(by amount: CGFloat) -> some InsettableShape {
        CachedShape<Base.InsetShape>(
            base.inset(by: amount),
            isActive: isActive,
            id: id
        )
    }
    
}

extension Shape {
    
    /// Reduces the amount of calls to the path function by caching its result on the heap.
    /// - Note: When active it will attempt to cache paths when possible and invalidate when it makes sense. When active is false it will bypass cache and act as a normal shape.
    /// - Note: Most paths are simple enough to build on the fly but if there a is a very complicated shape that is dynamically built to unknown complexity its a good idea to use a cached shape.
    /// - Parameter isActive: Bool indicating if cache should be active. Defaults to true.
    /// - Returns: A cached shape.
    nonisolated public func cache(isActive: Bool = true) -> some Shape {
        CachedShape(self, isActive: isActive, id: 0)
    }
    
}

extension Shape where Self : Hashable {
    
    /// Reduces the amount of calls to the path function by caching its result on the heap.
    /// - Note: When active it will attempt to cache paths when possible and invalidate when it makes sense. When active is false it will bypass cache and act as a normal shape.
    /// - Note: Most paths are simple enough to build on the fly but if there a is a very complicated shape that is dynamically built to unknown complexity its a good idea to use a cached shape.
    /// - Parameter isActive: Bool indicating if cache should be active. Defaults to true.
    /// - Returns: A cached shape.
    nonisolated public func cache(isActive: Bool = true) -> some Shape {
        CachedShape(self, isActive: isActive, id: hashValue)
    }
    
}


final class PathCacheStorage: @unchecked Sendable {
    
    static let shared = PathCacheStorage()
    
    private var elements: [Int : Element] = [:]
    private var removals: [Int : Task<Void, Error>] = [:]
    
    subscript(_ key: Int) -> Element? {
        get {
            removals[key]?.cancel()
            return elements[key]
        }
        set {
            if let newValue {
                elements[key] = newValue
            } else {
                scheduleRemoval(key)
            }
        }
    }
    
    private func scheduleRemoval(_ key: Int) {
        // cache is debounced by one second so if nothing changes for a second it will use the same instance.
        removals[key] = Task.detached{
            try await Task.sleep(for: .seconds(1))
            await MainActor.run { [weak self] in
                self?.elements[key] = nil
            }
        }
    }
    
    struct Element {
        
        let path: Path
        let sizeThatFits: CGSize
        var wasActive: Bool
        
        init(path: Path, sizeThatFits: CGSize, wasActive: Bool = true) {
            self.path = path
            self.sizeThatFits = sizeThatFits
            self.wasActive = wasActive
        }
        
    }
    
}

