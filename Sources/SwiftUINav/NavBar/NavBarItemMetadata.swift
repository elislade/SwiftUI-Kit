import Foundation

public struct NavBarItemMetadata: Equatable, Sendable {
    
    public enum Placement: UInt8, Equatable, CaseIterable, Sendable, CustomStringConvertible {
        case leading
        case trailing
        case title
        case accessory
        
        public var description: String {
            switch self {
            case .leading: "Leading"
            case .trailing: "Trailing"
            case .title: "Title"
            case .accessory: "Accessory"
            }
        }
    }
    
    let placement: Placement
    
}
