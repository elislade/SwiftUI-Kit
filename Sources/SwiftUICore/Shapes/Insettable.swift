import SwiftUI

public protocol Insettable {
    
    associatedtype Inset
    func inset(by amount: CGFloat) -> Inset
    
}


extension RoundedRectangle: Insettable {}
extension Circle: Insettable {}
extension Capsule: Insettable {}
extension Rectangle: Insettable {}
extension ContainerRelativeShape: Insettable {}
extension Ellipse: Insettable {}


public final class AnyInsettable: Insettable, @unchecked Sendable {
    
    let base: Any
    private var insettable: any Insettable { base as! any Insettable }
    
    public init<Inset: Insettable & Sendable>(_ base: Inset) {
        self.base = base
    }
    
    public func inset(by amount: CGFloat) -> Any {
        insettable.inset(by: amount)
    }
    
}
