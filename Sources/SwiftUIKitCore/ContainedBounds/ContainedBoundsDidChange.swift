import SwiftUI


struct DidChangeContainedBounds {
    
    @State private var id = UUID()
    
    let context: AnyHashable
    let action: (ContainedBoundsState) -> Void
    
}

extension DidChangeContainedBounds: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .anchorPreference(key: ContainedBoundsKey.self, value: .bounds){
                [.init(
                    id: id,
                    context: context,
                    anchor: $0,
                    didChangeVisibility: { state in
                        Task{ @MainActor in
                            action(state)
                        }
                    }
                )]
            }
    }
    
}

public struct ContainedBoundsState: Hashable, Sendable, BitwiseCopyable  {
    public enum Containment: Hashable, Sendable, BitwiseCopyable {
        case partially
        case fully
        case none
    }
    
    public let edges: Edge.Set
    public let containment: Containment
}
