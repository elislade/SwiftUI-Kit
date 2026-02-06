

public struct NavBarItemMetadata: Equatable, Sendable, BitwiseCopyable {
    
    public enum Placement: UInt8, Equatable, CaseIterable, Sendable, BitwiseCopyable {
        case leading
        case trailing
        case title
        case accessory
    }
    
    let placement: Placement
    let hidden: Bool
    let priority: UInt8
    
}
