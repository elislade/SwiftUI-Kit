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


// Pre iOS 16 Version of AnyShape
struct AnyShape: Shape {
    
    let shape: any Shape
    
    init<S: Shape>(_ shape: S) {
        self.shape = shape
    }
    
    func path(in rect: CGRect) -> Path {
        shape.path(in: rect)
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    nonisolated func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        shape.sizeThatFits(proposal)
    }
    
}
