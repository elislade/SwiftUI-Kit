import SwiftUI
import SwiftUIKitCore


struct PresentationWillDismissAction: Equatable, Sendable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let action: @MainActor () -> Void
    
    @MainActor func callAsFunction() -> Void {
        action()
    }
}


struct PresentationWillDismissPreferenceKey: PreferenceKey {
    
    typealias Value = [PresentationWillDismissAction]
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
    
    static var defaultValue: Value { [] }
    
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
