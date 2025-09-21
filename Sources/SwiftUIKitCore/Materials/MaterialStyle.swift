import SwiftUI

public protocol MaterialStyle {
    
    associatedtype Body: View
    
    @MainActor func makeBody(shape: AnyInsettableShape) -> Body
    
}

extension MaterialStyle {
    
    @MainActor func makeAnyBody(_ shape: any InsettableShape) -> AnyView {
        AnyView(makeBody(shape: AnyInsettableShape(shape)))
    }
    
}

public struct AnyMaterialStyle: MaterialStyle {
    
    private let style: any MaterialStyle
    
    public init(_ style: some MaterialStyle) {
        self.style = style
    }
    
    public func makeBody(shape: AnyInsettableShape) -> AnyView {
        style.makeAnyBody(shape)
    }
    
    @MainActor public func makeBody(_ shape: any InsettableShape) -> AnyView {
        style.makeAnyBody(AnyInsettableShape(shape))
    }
}


