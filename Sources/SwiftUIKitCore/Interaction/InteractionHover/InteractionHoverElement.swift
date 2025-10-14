import SwiftUI


struct InteractionHoverElementModifier {
    
    @Environment(\.interactionGroupCoordinateSpace) private var coordinateSpace
    @Environment(\.interactionHoverEnabled) private var enabled
    
    @State private var id: UUID = UUID()
    @State private var lastState: InteractionHoverPhase? = nil
    
    let action: (InteractionHoverPhase) -> Void
    
    nonisolated init(action: @escaping (InteractionHoverPhase) -> Void) {
        self.action = action
    }
    
}


extension InteractionHoverElementModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content.background {
            ZStack {
                if enabled {
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: InteractionHoverElementPreference.self,
                            value: enabled ? [.init(
                                id: id,
                                coordinateSpaceBounds: proxy.frame(in: coordinateSpace),
                                action: {
                                    lastState = nil
                                    lastState = $0
                                }
                            )] : []
                        )
                    }
                    .onChangePolyfill(of: lastState){
                        if let lastState {
                            action(lastState)
                        }
                    }
                }
            }
            .disableAnimations()
        }
    }
    
}


struct InteractionHoverElement: Equatable {
    
    static func == (lhs: InteractionHoverElement, rhs: InteractionHoverElement) -> Bool {
        lhs.id == rhs.id && lhs.coordinateSpaceBounds == rhs.coordinateSpaceBounds
    }
    
    let id: UUID
    let coordinateSpaceBounds: CGRect
    let action: (InteractionHoverPhase) -> Void
    
    func callAsFunction(_ phase: InteractionHoverPhase) {
        action(phase)
    }
    
}


struct InteractionHoverElementPreference: PreferenceKey {
    
    typealias Value = [InteractionHoverElement]
    
    static var defaultValue: Value { [] }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
    
}
