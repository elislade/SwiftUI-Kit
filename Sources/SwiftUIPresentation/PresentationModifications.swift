import SwiftUI
import SwiftUIKitCore


// MARK: - Backdrop

struct PresentationBackdropKeyValue: Equatable, Sendable {
    
    static func == (lhs: PresentationBackdropKeyValue, rhs: PresentationBackdropKeyValue) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let view: @MainActor () -> AnyView
    
}

struct PresentationBackdropInteractionKey: PreferenceKey {
    
    static var defaultValue: [PresentationBackdropInteraction] { [] }
    
    static func reduce(value: inout [PresentationBackdropInteraction], nextValue: () -> [PresentationBackdropInteraction]) {
        value.append(contentsOf: nextValue())
    }
    
}

struct PresentationBackdropKey: PreferenceKey {
    
    static var defaultValue: [PresentationBackdropKeyValue] { [] }
    
    static func reduce(value: inout [PresentationBackdropKeyValue], nextValue: () -> [PresentationBackdropKeyValue]) {
        value.append(contentsOf: nextValue())
    }
    
}

struct PresentationBackdropModifier<BG: View>: ViewModifier {
    
    @State private var id = UUID()
    
    let background: BG
    
    func body(content: Content) -> some View {
        content.preference(
            key: PresentationBackdropKey.self,
            value: [ .init(id: id, view: { AnyView(ZStack{ background }) }) ]
        )
    }
    
}

public extension View {
    
    func presentationBackdrop<C: View>(
        _ interaction: PresentationBackdropInteraction = .touchEndedDismiss,
        @ViewBuilder content: @escaping () -> C)
    -> some View {
        modifier(PresentationBackdropModifier(
            background: content()
        ))
        .preference(
            key: PresentationBackdropInteractionKey.self,
            value: [ interaction ]
        )
    }
    
    
    func presentationBackdrop(_ interaction: PresentationBackdropInteraction) -> some View {
        preference(
            key: PresentationBackdropInteractionKey.self,
            value: [ interaction ]
        )
    }
    
}


public enum PresentationBackdropInteraction: Sendable {
    case touchEndedDismiss
    case touchChangeDismiss
    case disabled
}


// MARK: - Presentation Depth


struct PresentationDepthKey: EnvironmentKey {
    
    static var defaultValue: Int { 0 }
    
}


extension EnvironmentValues {
    
    public var presentationDepth: Int {
        get { self[PresentationDepthKey.self] }
        set { self[PresentationDepthKey.self] = newValue }
    }
    
}
