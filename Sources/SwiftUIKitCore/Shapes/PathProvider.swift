import SwiftUI


public protocol PathProvider: Sendable {
    
    func path(in rect: CGRect) -> Path
    
}

public struct AnyPathProvider: PathProvider {
    
    let base: any PathProvider
    
    public nonisolated init<Provider: PathProvider>(_ base: Provider) {
        self.base = base
    }
    
    public func path(in rect: CGRect) -> Path {
        base.path(in: rect)
    }
    
}

public struct PathProviderShape: Shape {
    
    let provider: PathProvider
    
    init(_ provider: PathProvider) {
        self.provider = provider
    }
    
    public func path(in rect: CGRect) -> Path {
        provider.path(in: rect)
    }
}

extension RoundedRectangle: PathProvider {}
extension Circle: PathProvider {}
extension Capsule: PathProvider {}
extension Rectangle: PathProvider {}
extension AsymmetricRoundedRectangle {}
extension ContainerRelativeShape: PathProvider {}
extension Ellipse: PathProvider {}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension AnyShape: PathProvider {}
