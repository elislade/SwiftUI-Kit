import SwiftUI


public extension Color {
    
    static var random: Color {
        Color(
            hue: .random(in: 0...1),
            saturation: .random(in: 0...1),
            brightness: .random(in: 0...1)
        )
    }
    
}
