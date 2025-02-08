import SwiftUI
import SwiftUIKitCore


public struct PresentationWillDismissAction: Equatable, Sendable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let action: @MainActor () -> Void
    
    @MainActor public func callAsFunction() -> Void {
        action()
    }
    
}


public struct PresentationWillDismissPreferenceKey: PreferenceKey {
    
    public typealias Value = [PresentationWillDismissAction]
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
    
    public static var defaultValue: Value { [] }
    
}


public extension View {
    
    func onPresentationWillDismiss(perform action: @MainActor @escaping () -> Void) -> some View {
        InlineState(UUID()){ id in
            preference(
                key: PresentationWillDismissPreferenceKey.self,
                value: [.init(id: id.uuidString, action: action)]
            )
        }
    }
    
    func disableOnPresentationWillDismiss(_ disabled: Bool = true) -> some View {
        transformPreference(PresentationWillDismissPreferenceKey.self){ value in
            if disabled {
                value = []
            }
        }
    }
    
}
