import SwiftUI
import SwiftUIKitCore

public protocol PresentationValueConformable {
    var id: UUID { get }
    var tag: String? { get }
    var anchor: Anchor<CGRect> { get }
    var includeAnchorInEquatance: Bool { get }
    var view: AnyView { get }
    var dispose: () -> Void { get }
    var requestIDChange: (UUID?) -> Void { get }
    var envProxy: ClosureKeyPath<EnvironmentValues> { get }
}

protocol TranslatorTest {
    associatedtype Translation
    static func translate(source: Self) -> Translation
}

public protocol Translatable {
    associatedtype Translation
    func translate() -> Translation
}


@dynamicMemberLookup public struct PresentationValue<Metadata: Equatable>: Equatable, PresentationValueConformable {
    
    public static func == (lhs: PresentationValue, rhs: PresentationValue) -> Bool {
        var values: [Bool] = [lhs.id == rhs.id, lhs.tag == rhs.tag]
        if lhs.includeAnchorInEquatance && rhs.includeAnchorInEquatance {
            values.append(lhs.anchor == rhs.anchor)
        }
        values.append(lhs.metadata == rhs.metadata)
        return values.allSatisfy({ $0 })
    }
    
    public let id: UUID
    public let tag: String?
    public let metadata: Metadata
    public let anchor: Anchor<CGRect>
    public let includeAnchorInEquatance: Bool
    public let view: AnyView
    public let dispose: () -> Void
    public let requestIDChange: (UUID?) -> Void
    public let envProxy: ClosureKeyPath<EnvironmentValues>
    
    init(
        id: UUID,
        tag: String?,
        metadata: Metadata,
        anchor: Anchor<CGRect>,
        includeAnchorInEquatance: Bool = true,
        view: AnyView,
        dispose: @escaping () -> Void,
        requestIDChange: @escaping (UUID?) -> Void = { _ in },
        envProxy: ClosureKeyPath<EnvironmentValues>
    ) {
        self.id = id
        self.tag = tag
        self.metadata = metadata
        self.anchor = anchor
        self.includeAnchorInEquatance = includeAnchorInEquatance
        self.view = view
        self.dispose = dispose
        self.requestIDChange = requestIDChange
        self.envProxy = envProxy
    }
    
    public init(other: PresentationValueConformable, metadata: Metadata) {
        self.id = other.id
        self.tag = other.tag
        self.metadata = metadata
        self.anchor = other.anchor
        self.includeAnchorInEquatance = other.includeAnchorInEquatance
        self.view = other.view
        self.dispose = other.dispose
        self.requestIDChange = other.requestIDChange
        self.envProxy = other.envProxy
    }
    
    public subscript<V>(dynamicMember path: KeyPath<Metadata, V>) -> V {
        metadata[keyPath: path]
    }
    
    public subscript<V>(dynamicMember path: KeyPath<EnvironmentValues, V>) -> V {
        envProxy[path]
    }
    
}


public extension PresentationValue where Metadata: EmptyInitalizable {
    
    init(_ other: PresentationValueConformable) {
        self.init(other: other, metadata: .init())
    }
    
}


public extension PresentationValue {
    
    init<T: Translatable>(_ other: PresentationValue<T>) where T.Translation == Metadata {
        self.init(
            id: other.id,
            tag: other.tag,
            metadata: other.metadata.translate(),
            anchor: other.anchor,
            includeAnchorInEquatance: other.includeAnchorInEquatance,
            view: other.view,
            dispose: other.dispose,
            requestIDChange: other.requestIDChange,
            envProxy: other.envProxy
        )
    }
    
}

public extension View {
    
    func presentationValue<Metadata: Equatable, Content: View>(
        behaviour: PresentationIdentityBehaviour = .stable,
        isPresented: Binding<Bool>,
        tag: String? = nil,
        respondsToBoundsChange: Bool = false,
        metadata: Metadata,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(EnvironmentModifierWrap {
            PresentationValuePresenter(
                environment: $0,
                behaviour: behaviour,
                isPresented: isPresented,
                tag: tag,
                presentationRespondsToBoundsChange: respondsToBoundsChange,
                metadata: metadata,
                presentation: content
            )
        })
    }
    
    func presentationValue<Value, Metadata: Equatable, Content: View>(
        behaviour: PresentationIdentityBehaviour = .stable,
        value: Binding<Value?>,
        tag: String? = nil,
        respondsToBoundsChange: Bool = false,
        metadata: Metadata,
        @ViewBuilder content: @escaping (Value) -> Content
    ) -> some View {
        modifier(EnvironmentModifierWrap{
            PresentationOptionalValuePresenter(
                environment: $0,
                behaviour: behaviour,
                value: value,
                tag: tag,
                presentationRespondsToBoundsChange: respondsToBoundsChange,
                metadata: metadata,
                presentation: content
            )
        })
    }
    
}

public struct PresentationKey<Metadata: Equatable>: PreferenceKey {
    
    public static var defaultValue: [PresentationValue<Metadata>] { [] }
    
    public static func reduce(value: inout [PresentationValue<Metadata>], nextValue: () -> [PresentationValue<Metadata>]) {
        value.append(contentsOf: nextValue())
    }
    
}

/// `PresentationIdentityBehaviour` gives control over how presentation id is to be handled. By default most implimentations should use `.stable` as default as it's most performant.
/// - Note: Since presentation views are type erased to `AnyView` it's recommended that all state needed for a presentation view be inside of it or passed to it through a binding as this will **NOT** be effected by the `AnyView` type eraser. Doing this along with `.stable` behaviour will lead to the most performant presentation.  If you use `.changeOnUpdate` behaviour you don't need to worry about the presentation view wrapping its own state, so you can pass state through normal let vars and from values in the view managing the presentation, but with a tradeoff that the preference key delivering this presentation will re-evaluate on every view update even if the view has no state changes.
/// - Note: This behaviour is only for id of the presentation preference if any other component of the preference value changes such as `tag`, `anchor`, or `metadata`, the view will be re-evaluated.
public enum PresentationIdentityBehaviour: Hashable {
    
    /// The presentation id will only update on view setup.
    /// - Note: This is the most performant out of all the options as the presentation id for the preference key will be updated once.
    case stable
    
    /// The presentation id will update on every view update cycle.
    /// - Note: This is the least performant as it will update when any view updates are detected.
    case changeOnUpdate
    
    /// The presentation id will change with a custom hashable value.
    /// - Note: Performance is dependant on how often the Hashable value is updated.
    case custom(AnyHashable)
    
    
    public var customHashable: AnyHashable? {
        if case .custom(let anyHashable) = self {
            return anyHashable
        } else { return nil }
    }
    
    
    public var isStable: Bool { self == .stable }
    
}



public enum PresentationEnvironmentBehaviour {
    
    /// uses the environment of the presentation
    case usePresentation
    
    /// uses the environment of the  context
    case useContext
    
}
