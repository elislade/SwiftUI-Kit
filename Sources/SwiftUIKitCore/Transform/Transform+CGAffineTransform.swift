import SwiftUI


public extension Transform {
    
    nonisolated var cgAffine: CGAffineTransform {
        self[Component.allCases]
    }
    
    nonisolated subscript(component: Component) -> CGAffineTransform {
        switch component {
        case .scale: CGAffineTransform(scaleX: scale.x, y: scale.y)
        case .rotation: CGAffineTransform(rotationAngle: rotation.radians)
        case .shear: CGAffineTransform(shearX: shear.x, shearY: shear.y)
        case .translation: CGAffineTransform(translationX: translation.x, y: translation.y)
        }
    }
    
    nonisolated subscript(components: Component...) -> CGAffineTransform {
        self[components]
    }
    
    nonisolated subscript(components: [Component]) -> CGAffineTransform {
        var result: CGAffineTransform = .identity
        for component in components {
            result = result.concatenating(self[component])
        }
        return result
    }
    
}


public extension CGAffineTransform {
    
    nonisolated init(shearX: Double, shearY: Double){
        self.init(
            1, tan(shearX),
            tan(shearY), 1,
            0, 0
        )
    }
    
}
