import SwiftUI


public struct RaisedMaterial: MaterialStyle {
    
    var base: Material = .regular
    
    public func makeBody(shape: AnyInsettableShape) -> some View {
        ZStack{
            shape.fill(
                base.shadow(.drop(color: .black.opacity(0.15), radius: 20, y: 10))
            )
            
            shape.material(.contrastOutline)
        }
    }
    
}

extension MaterialStyle where Self == RaisedMaterial {
    
    public static var raised: Self {
        .init()
    }
    
    public static func raised(_ material: Material) -> Self {
        .init(base: material)
    }
    
}
