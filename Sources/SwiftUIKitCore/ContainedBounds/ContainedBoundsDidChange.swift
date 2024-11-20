import SwiftUI


struct DidChangeContainedBounds: ViewModifier {
    
    @State private var id = UUID()
    
    let context: AnyHashable
    let action: (ContainedBoundsState) -> Void
    
    func body(content: Content) -> some View {
        content
            .anchorPreference(key: ContainedBoundsKey.self, value: .bounds){
                [.init(
                    id: id,
                    context: context,
                    anchor: $0,
                    didChangeVisibility: { isVisible in
                        DispatchQueue.main.async{
                            action(isVisible)
                        }
                    }
                )]
            }
    }
    
}


public enum ContainedBoundsState: Hashable, Sendable {
    case partiallyContained(edges: Edge.Set = [])
    case fullyContained
    case notContained
    
    public var hasContainment: Bool {
        if case .fullyContained = self {
            return true
        }
        return self == .fullyContained
    }
}
