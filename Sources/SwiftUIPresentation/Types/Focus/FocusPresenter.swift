import SwiftUI
import SwiftUIKitCore

struct FocusPresenter<Value: ValuePresentable, Focus: View>: ViewModifier {
    
    @Namespace private var ns
    
    @State private var active = false
    @State private var showMatch = true
    
    @Binding private var value: Value

    let focusView: @MainActor (Value.Presented) -> Focus
    let accessory: @MainActor () -> AnyView?
    
    nonisolated init(
        value: Binding<Value>,
        focusView: @MainActor @escaping (Value.Presented) -> Focus,
        accessory: @MainActor @escaping () -> AnyView? = { nil }
    ) {
        self._value = value
        self.focusView = focusView
        self.accessory = accessory
    }
    
    func body(content: Content) -> some View {
        content
            .allowsHitTesting(!value.isPresented)
            .disabled(value.isPresented)
            .opacity(active ? 0 : 1)
            .animation(.none, value: active)
            .overlay {
                ZStack {
                    if active {
                        ZStack {
                            if showMatch {
                                content
                                    .matchedGeometryEffect(id: "Item", in: ns)
                                    .transition((.scale(0.9) + .opacity).animation(.bouncy))
                            } else {
                                Color.clear.onDisappear{ active = false }
                            }
                        }
                        .onAppear{ showMatch = false }
                        .animation(.smooth.speed(1.3), value: showMatch)
                        .transition(.identity)
                    }
                }
                .onDisappear{ showMatch = true }
            }
            .onChangePolyfill(of: value.isPresented){
                if value.isPresented {
                    active = true
                } else {
                    active = true
                    showMatch = true
                }
            }
            .presentationValue(
                value: $value,
                metadata: FocusPresentationMetadata(
                    namespace: ns,
                    accessory: accessory
                ),
                content: focusView
            )
    }
    
}
