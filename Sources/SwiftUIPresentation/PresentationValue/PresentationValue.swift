import SwiftUI
import SwiftUIKitCore

public protocol PresentationValueConformable: Sendable {
    var id: UUID { get }
    var tag: String? { get }
    var anchor: Anchor<CGRect> { get }
    var includeAnchorInEquatance: Bool { get }
    var view: @MainActor () -> AnyView { get }
    var dispose: @Sendable () -> Void { get }
    var requestIDChange: @Sendable (UUID?) -> Void { get }
    var envProxy: ClosureKeyPath<EnvironmentValues> { get }
}


public protocol Translatable {
    associatedtype Translation
    func translate() -> Translation
}


@dynamicMemberLookup public struct PresentationValue<Metadata: Equatable & Sendable>: Equatable, PresentationValueConformable, Sendable {
    
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
    public let view: @MainActor () -> AnyView
    public let dispose: @Sendable () -> Void
    public let requestIDChange: @Sendable (UUID?) -> Void
    public let envProxy: ClosureKeyPath<EnvironmentValues>
    
    init(
        id: UUID,
        tag: String?,
        metadata: Metadata,
        anchor: Anchor<CGRect>,
        includeAnchorInEquatance: Bool = true,
        view: @escaping @MainActor () -> AnyView,
        dispose: @Sendable @escaping () -> Void,
        requestIDChange: @Sendable @escaping (UUID?) -> Void = { _ in },
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
    
    public subscript<V: Sendable>(dynamicMember path: KeyPath<Metadata, V>) -> V {
        metadata[keyPath: path]
    }
    
    public subscript<V: Sendable>(dynamicMember path: KeyPath<EnvironmentValues, V>) -> V {
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
    
    func presentationValue<Metadata: Equatable & Sendable, Content: View>(
        isPresented: Binding<Bool>,
        tag: String? = nil,
        respondsToBoundsChange: Bool = false,
        metadata: Metadata,
        @ViewBuilder content: @MainActor @escaping () -> Content
    ) -> some View {
        modifier(EnvironmentModifierWrap { environment in
            PresentationValueBoolPresenter(
                environmentRef: ClosureKeyPath(environment),
                isPresented: isPresented,
                tag: tag,
                presentationRespondsToBoundsChange: respondsToBoundsChange,
                metadata: metadata,
                presentation: content
            )
        })
    }
    
    func presentationValue<Value, Metadata: Equatable & Sendable, Content: View>(
        value: Binding<Value?>,
        tag: String? = nil,
        respondsToBoundsChange: Bool = false,
        metadata: Metadata,
        @ViewBuilder content: @MainActor @escaping (Value) -> Content
    ) -> some View {
        modifier(EnvironmentModifierWrap{ environment in
            PresentationValueOptionalPresenter(
                environmentRef: ClosureKeyPath(environment),
                value: value,
                tag: tag,
                presentationRespondsToBoundsChange: respondsToBoundsChange,
                metadata: metadata,
                presentation: content
            )
        })
    }
    
}

public struct PresentationKey<Metadata: Equatable & Sendable>: PreferenceKey {
    
    public static var defaultValue: [PresentationValue<Metadata>] { [] }
    
    public static func reduce(value: inout [PresentationValue<Metadata>], nextValue: () -> [PresentationValue<Metadata>]) {
        value.append(contentsOf: nextValue())
    }
    
}
