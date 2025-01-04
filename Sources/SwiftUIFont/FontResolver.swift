

public protocol FontResolver {
    
    func resolve(resource: FontResource, with parameters: FontParameters) -> ResolvedFont
    
}


extension Never : FontResolver {
    
    public func resolve(resource: FontResource, with parameters: FontParameters) -> ResolvedFont {
        fatalError()
    }
    
}
