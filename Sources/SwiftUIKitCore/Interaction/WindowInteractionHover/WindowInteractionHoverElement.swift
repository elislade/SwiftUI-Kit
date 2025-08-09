import SwiftUI


struct WindowInteractionHoverElementModifier {
    
    @Environment(\.windowInteractionHoverEnabled) private var enabled
    @State private var id: UUID = UUID()
    let action: (WindowInteractionHoverPhase) -> Void
    
    nonisolated init(action: @escaping (WindowInteractionHoverPhase) -> Void) {
        self.action = action
    }
    
}


extension WindowInteractionHoverElementModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content.background {
            ZStack {
                if enabled {
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: WindowInteractionHoverElementPreference.self,
                            value: enabled ? [.init(id: id, windowBounds: proxy.frame(in: .global), action: action)] : []
                        )
                    }
                }
            }
            .disableAnimations()
        }
    }
    
}


struct WindowInteractionHoverElement {
    
    let id: UUID
    let windowBounds: CGRect
    let action: (WindowInteractionHoverPhase) -> Void
    
    func callAsFunction(_ phase: WindowInteractionHoverPhase) {
        action(phase)
    }
    
}


struct WindowInteractionHoverElementPreference: PreferenceKey {
    
    typealias Value = [WindowInteractionHoverElement]
    
    static var defaultValue: Value { [] }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
    
}
