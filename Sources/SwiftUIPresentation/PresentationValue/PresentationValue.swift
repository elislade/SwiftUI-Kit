import SwiftUI
import SwiftUIKitCore

@dynamicMemberLookup public struct PresentationValue<Metadata>: Identifiable {
    
    internal let includeAnchorInEquatance: Bool
    
    public let id: UniqueID
    public let metadata: Metadata
    public let anchor: Anchor<CGRect>
    public let view: AnyView
    public let dispose: @MainActor () -> Void
    public let wantsDisposal: Bool
    public let environment: MainActorClosureKeyPath<EnvironmentValues>
    
    /// Initializes instance
    /// - Parameters:
    ///   - id: The unique ID of this presentation.
    ///   - metadata: Specific presentation metadata.
    ///   - anchor: The Geometry Anchor of the view that is hoisting this presentation.
    ///   - includeAnchorInEquatance: `Bool` indicating whether to use the anchors value in equatance. Defaults to `true`.
    ///   - view: The View that should be presented.
    ///   - wantsDisposal: `Bool` indicating to the context to dispose of internal state for this presentation. Defaults to `false`.
    ///   - dispose: A closure that tells the presenter it should be disposed of, allowing it to update internal state.
    ///   - environment: An environment reference from the point of view of the presenter.
    public init(
        id: UniqueID,
        metadata: Metadata,
        anchor: Anchor<CGRect>,
        includeAnchorInEquatance: Bool = true,
        view: some View,
        wantsDisposal: Bool = false,
        dispose: @MainActor @escaping () -> Void,
        environment: MainActorClosureKeyPath<EnvironmentValues>
    ) {
        self.id = id
        self.metadata = metadata
        self.anchor = anchor
        self.includeAnchorInEquatance = includeAnchorInEquatance
        self.view = AnyView(view)
        self.dispose = dispose
        self.wantsDisposal = wantsDisposal
        self.environment = environment
    }
    
    public subscript<Subject>(dynamicMember path: KeyPath<Metadata, Subject>) -> Subject {
        metadata[keyPath: path]
    }
    
    @MainActor public subscript<Subject>(dynamicMember path: KeyPath<EnvironmentValues, Subject>) -> Subject {
        environment[path]
    }
    
}


extension PresentationValue: Equatable where Metadata: Equatable {
    
    public static func == (lhs: PresentationValue, rhs: PresentationValue) -> Bool {
        let base = lhs.id == rhs.id
        && lhs.metadata == rhs.metadata
        && lhs.wantsDisposal == rhs.wantsDisposal
        
        if lhs.includeAnchorInEquatance && rhs.includeAnchorInEquatance {
            return base && lhs.anchor == rhs.anchor
        } else {
            return base
        }
    }
    
}


extension View {
    
    public func presentationValue<Metadata>(
        isPresented: Binding<Bool>,
        respondsToBoundsChange: Bool = false,
        metadata: Metadata,
        @ViewBuilder content: @MainActor @escaping () -> some View
    ) -> some View {
        presentationValue(
            value: isPresented,
            respondsToBoundsChange: respondsToBoundsChange,
            metadata: metadata,
            content: { _ in content() }
        )
    }
    
    public func presentationValue<Value: ValuePresentable, Metadata>(
        value: Binding<Value>,
        respondsToBoundsChange: Bool = false,
        metadata: Metadata,
        @ViewBuilder content: @MainActor @escaping (Value.Presented) -> some View
    ) -> some View {
        modifier(EnvironmentModifierWrap{ environment in
            PresentationValuePresenter(
                environment: MainActorClosureKeyPath(environment),
                updatesOnBoundsChange: respondsToBoundsChange,
                value: value,
                metadata: metadata,
                presentation: content
            )
        })
        .routeRelayReceiver()
    }
    
    nonisolated public func presentationHandler<Metadata: Equatable>(
        _ meta: Metadata.Type = Metadata.self,
        active: Bool = true,
        perform action: @escaping ([PresentationValue<Metadata>]) -> ()
    ) -> some View {
        onPreferenceChange(PresentationKey<Metadata>.self){
            if active { action($0) }
        }
        .preferenceKeyReset(PresentationKey<Metadata>.self, reset: active)
    }
    
    nonisolated public func presentationOverlay<Metadata>(
        _ meta: Metadata.Type = Metadata.self,
        @ViewBuilder content: @escaping ([PresentationValue<Metadata>]) -> some View
    ) -> some View {
        overlayPreferenceValue(PresentationKey<Metadata>.self, content)
            .preferenceKeyReset(PresentationKey<Metadata>.self)
    }
        
}

public struct PresentationKey<Metadata>: PreferenceKey {
    
    public typealias Value = [PresentationValue<Metadata>]
    
    public static var defaultValue: Value { [] }
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
    
}
