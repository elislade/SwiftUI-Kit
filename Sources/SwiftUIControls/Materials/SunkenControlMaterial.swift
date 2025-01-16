import SwiftUI
import SwiftUIKitCore


public struct SunkenControlMaterial<Shape: InsettableShape>: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    let shape: Shape
    let isTinted: Bool
    
    public init(_ shape: Shape, isTinted: Bool = false) {
        self.shape = shape
        self.isTinted = isTinted
    }
    
    public var body: some View {
        ZStack {
            shape
                .fill(Color(white: colorScheme == .light ? 0.9 : 0.2))
                
            shape
                .fill(.tint)
                .opacity(isTinted ? 1 : 0)
            
            shape
                .fill(.linearGradient(
                    colors: [.black.opacity(0.3), .white.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                //.opacity(0.5)
                .blendMode(.overlay)
            
            shape
                .strokeBorder(lineWidth: 0.5)
                .opacity(0.2)
            
            shape
                .strokeBorder()
                .opacity(0.2)
                .blur(radius: 3)
                .offset(y: 1)
        }
        .clipShape(shape)
        .blendMode(isTinted ? .normal : .luminosity)
    }
    
}


public extension SunkenControlMaterial where Shape == Rectangle {
    
    @inlinable init(isTinted: Bool = false){
        self.init(Rectangle(), isTinted: isTinted)
    }
    
}


#Preview {
    HStack {
        SunkenControlMaterial(Circle())
        SunkenControlMaterial(Circle(), isTinted: true)
    }
    .padding()
}
