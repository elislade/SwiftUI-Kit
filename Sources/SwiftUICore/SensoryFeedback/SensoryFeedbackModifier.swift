import SwiftUI

#if os(iOS)

struct ImpactFeedbackModifier<Value: Equatable>: ViewModifier {
    
    let value: Value
    let intensity: Double
    
    @State private var feedback: UIImpactFeedbackGenerator!

    init(style: ImpactFeedbackStyle = .medium, intensity: Double = 1, value: Value) {
        self.intensity = intensity
        self.value = value
        _feedback = State(initialValue: UIImpactFeedbackGenerator(style: .init(rawValue: style.rawValue)!))
    }
    
    func body(content: Content) -> some View {
        content.onChange(of: value){ _ in
            feedback.impactOccurred(intensity: intensity)
        }
    }
    
}

struct SelectionFeedbackModifier<Value: Equatable>: ViewModifier {
    
    let value: Value
    
    @State private var selection = UISelectionFeedbackGenerator()
    
    init(value: Value) {
        self.value = value
    }
    
    func body(content: Content) -> some View {
        content.onChange(of: value){ _ in
            selection.selectionChanged()
        }
    }
    
}

#endif

struct SensoryFeedbackModifier<V: Equatable>: ViewModifier {
    
    let value: V
    let type: FeedbackType
    
    init(type: FeedbackType = .selectionChange, value: V) {
        self.type = type
        self.value = value
    }
    
    func body(content: Content) -> some View {
        #if os(iOS)
        content.background {
            switch type {
            case .impact(let style, let intensity):
                Color.clear.modifier(ImpactFeedbackModifier(style: style, intensity: intensity, value: value))
            case .selectionChange:
                Color.clear.modifier(SelectionFeedbackModifier(value: value))
            }
        }
        #else
        content
        #endif
    }
    
}
