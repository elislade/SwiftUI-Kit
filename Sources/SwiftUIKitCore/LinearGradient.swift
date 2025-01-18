import SwiftUI


public extension LinearGradient {
    
    static func topToBottom(_ gradient: Gradient) -> LinearGradient {
        LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
    }
    
    static func leftToRight(_ gradient: Gradient) -> LinearGradient {
        LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
    }
    
    /// Rotates a Gradient by an angle and returns it as a LinearGradient.
    /// - Parameters:
    ///   - gradient: The `Gradient` to rotate.
    ///   - angle: The `Angle` to rotate by.
    /// - Returns: A `LinearGradient`.
    static func rotated(_ gradient: Gradient, angle: Angle) -> LinearGradient {
        let start = UnitPoint.leading.rotateAroundCenter(by: angle)
        
        return LinearGradient(
            gradient: gradient,
            startPoint: start,
            endPoint: start.inverse
        )
    }
    
}


public extension Color {
    
    var asGradient: some View {
        overlay{
            LinearGradient.topToBottom(
                Gradient(colors: [Color.white.opacity(0.2), Color.black.opacity(0.2)])
            )
            .blendMode(.overlay)
        }
        .drawingGroup()
    }
    
}

public extension UnitPoint {
    
    /// Computes the inverse of a `UnitPoint`.
    var inverse: UnitPoint {
        UnitPoint(x: 1 - x, y: 1 - y)
    }
    
    /// Rotates a `UnitPoint` arounds its center by a given `Angle`.
    /// - Parameter angle: The `Angle` to rotate by.
    /// - Returns: A `UnitPoint`.
    func rotateAroundCenter(by angle: Angle) -> UnitPoint {
        let offset = UnitPoint(x: x - 0.5, y: y - 0.5)
        let _x = (offset.x * Darwin.cos(angle.radians)) - (offset.y * sin(angle.radians))
        let _y = (offset.y * Darwin.cos(angle.radians)) + (offset.x * sin(angle.radians))
        return UnitPoint(x: _x + 0.5, y: _y + 0.5)
    }
    
}
