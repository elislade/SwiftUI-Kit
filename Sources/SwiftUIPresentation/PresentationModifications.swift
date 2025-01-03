import SwiftUI
import SwiftUIKitCore


// MARK: - Background

struct PresentationBackgroundKeyValue: Equatable, Sendable {
    
    static func == (lhs: PresentationBackgroundKeyValue, rhs: PresentationBackgroundKeyValue) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let view: @MainActor () -> AnyView
    
}

struct PresentationBackgroundInteractionKey: PreferenceKey {
    
    static var defaultValue: [PresentationBackgroundInteraction] { [] }
    
    static func reduce(value: inout [PresentationBackgroundInteraction], nextValue: () -> [PresentationBackgroundInteraction]) {
        value.append(contentsOf: nextValue())
    }
    
}

struct PresentationBackgroundKey: PreferenceKey {
    
    static var defaultValue: [PresentationBackgroundKeyValue] { [] }
    
    static func reduce(value: inout [PresentationBackgroundKeyValue], nextValue: () -> [PresentationBackgroundKeyValue]) {
        value.append(contentsOf: nextValue())
    }
    
}

struct PresentationBackgroundModifier<BG: View>: ViewModifier {
    
    @State private var id = UUID()
    
    let background: BG
    
    func body(content: Content) -> some View {
        content.preference(
            key: PresentationBackgroundKey.self,
            value: [ .init(id: id, view: { AnyView(ZStack{ background }) }) ]
        )
    }
    
}

public extension View {
    
    func presentationBackground<C: View>(
        _ interaction: PresentationBackgroundInteraction = .touchEndedDismiss,
        @ViewBuilder content: @escaping () -> C)
    -> some View {
        modifier(PresentationBackgroundModifier(
            background: content()
        ))
        .preference(
            key: PresentationBackgroundInteractionKey.self,
            value: [ interaction ]
        )
    }
    
    
    func presentationBackground(_ interaction: PresentationBackgroundInteraction) -> some View {
        preference(
            key: PresentationBackgroundInteractionKey.self,
            value: [ interaction ]
        )
    }
    
}


public enum PresentationBackgroundInteraction: Sendable {
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
