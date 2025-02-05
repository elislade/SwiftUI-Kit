import SwiftUI
import SwiftUIKitCore


public struct DismissPresentationAction: Equatable {
    
    public static func == (lhs: DismissPresentationAction, rhs: DismissPresentationAction) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let closure: @MainActor () -> Void
    
    public init(id: UUID = .init(), closure: @MainActor @escaping () -> Void) {
        self.id = id
        self.closure = closure
    }
    
    @MainActor public func callAsFunction() {
        closure()
    }
    
}

struct DismissPresentation: EnvironmentKey {
    
    static var defaultValue: DismissPresentationAction {
        .init(id: .init(), closure: {})
    }
    
}

public extension EnvironmentValues {
    
    var dismissPresentation: DismissPresentationAction {
        get { self[DismissPresentation.self] }
        set { self[DismissPresentation.self] = newValue }
    }
    
}


public extension View {
    
    func handleDismissPresentation(_ action: @MainActor @escaping () -> Void) -> some View {
        InlineState(UUID()){ id in
            InlineEnvironmentReader(\.isBeingPresentedOn){ isBeingPresentedOn in
                self.transformEnvironment(\.dismissPresentation) { value in
                    // only set value if view is not being presented on
                    if isBeingPresentedOn == false {
                        value = .init(id: id, closure: action)
                    }
                }
            }
        }
    }
    
}
