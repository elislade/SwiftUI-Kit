

public final class FontCacheResolver : FontResolver {
    
    private let resolver: FontResolver
    private var cache: [Int : ResolvedFont] = [:]
    
    public init(_ resolver: FontResolver) {
        self.resolver = resolver
    }
    
    public func resolve(resource: FontResource, with parameters: FontParameters) -> ResolvedFont {
        let key = hash(for: resource, with: parameters)
        if let cachedFont = cache[key] {
            return cachedFont
        }
        let resolvedFont = resolver.resolve(resource: resource, with: parameters)
        cache[key] = resolvedFont
        return resolver.resolve(resource: resource, with: parameters)
    }
    
    private func hash(for resource: FontResource, with parameters: FontParameters) -> Int {
        var hasher = Hasher()
        hasher.combine(resource)
        hasher.combine(parameters)
        return hasher.finalize()
    }
    
    public func clear() {
        cache.removeAll()
    }
    
}
