import Foundation

public struct NavBarItemMetadata: Equatable, Sendable, BitwiseCopyable {
    
    public enum Placement: UInt8, Equatable, CaseIterable, CustomStringConvertible, Sendable, BitwiseCopyable {
        case leading
        case trailing
        case title
        case accessory
        case none
        
        public var description: String {
            switch self {
            case .leading: "Leading"
            case .trailing: "Trailing"
            case .title: "Title"
            case .accessory: "Accessory"
            case .none: "None"
            }
        }
    }
    
    let placement: Placement
    
}
