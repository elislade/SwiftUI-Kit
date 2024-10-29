import Foundation

public struct InteractionEvent: Equatable, Sendable {
    
    enum Source {
        /// Finger or other conductive object that directly corrisponds to UI element frames.
        case directTouch
        
        /// Finger or other conductive object that indirectly interacts with UI by translating events on an external surface to the UI surface. E.G a trackpad.
        case indirectTouch
        
        case mouse
        
        case pencil
        
        var granularity: Double {
            switch self {
            case .directTouch: 0.5
            case .indirectTouch: 0.5
            case .mouse: 1
            case .pencil: 1
            }
        }
        
    }
    
    public let location: CGPoint
    
    public init(location: CGPoint) {
        self.location = location
    }
    
}
