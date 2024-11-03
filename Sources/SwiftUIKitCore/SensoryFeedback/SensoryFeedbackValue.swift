import SwiftUI


public enum FeedbackType {
    case impact(style: ImpactFeedbackStyle = .medium, intensity: Double = 1)
    case selectionChange
}

public enum ImpactFeedbackStyle : Int, @unchecked Sendable {
    case light = 0
    case medium = 1
    case heavy = 2
    case soft = 3
    case rigid = 4
}


@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(visionOS, unavailable)
extension SensoryFeedback {
    
    static func map(type: FeedbackType) -> SensoryFeedback {
        switch type {
        case let .impact(style, intensity):
            return .impact(weight: .map(style: style), intensity: intensity)
        case .selectionChange:
            return .selection
        }
    }
    
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(visionOS, unavailable)
extension SensoryFeedback.Weight {
    
    static func map(style: ImpactFeedbackStyle) -> SensoryFeedback.Weight {
        switch style {
        case .light: return .light
        case .medium: return .medium
        case .heavy: return .heavy
        case .soft: return .light
        case .rigid: return .heavy
        }
    }
    
}
