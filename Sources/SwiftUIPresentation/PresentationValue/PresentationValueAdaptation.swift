import SwiftUI
import SwiftUIKitCore


public protocol Adaptable<Source, Destination> {
    
    associatedtype Source
    associatedtype Destination
    
    func adapt(_ value: Source) -> Destination
    
}

extension Adaptable {
    
    public func callAsFunction(_ value: Source) -> Destination {
        adapt(value)
    }
    
}

public struct AnyAdaptor<Source, Destination> : Adaptable {
    
    private let base: any Adaptable<Source, Destination>
    
    public init(_ base: some Adaptable<Source, Destination>) {
        self.base = base
    }
    
    public func adapt(_ value: Source) -> Destination {
        base(value)
    }
    
}

public struct PresentationValueMetaAdaptor<Adaptor: Adaptable> : Adaptable {
    
    public typealias Source = PresentationValue<Adaptor.Source>
    public typealias Destination = PresentationValue<Adaptor.Destination>

    let adaptor: Adaptor
    
    public init(_ adaptor: Adaptor) {
        self.adaptor = adaptor
    }
    
    public func adapt(_ value: Source) -> Destination {
        .init(
            id: value.id,
            metadata: adaptor(value.metadata),
            anchor: value.anchor,
            includeAnchorInEquatance: value.includeAnchorInEquatance,
            view: value.view,
            wantsDisposal: value.wantsDisposal,
            dispose: value.dispose,
            environment: value.environment
        )
    }
    
}


extension View {
        
    nonisolated public func presentationAdaptation<A: Adaptable>(_ adaptor: A, enabled: Bool = true) -> some View where A.Source: Equatable {
        modifier(PresentationAdaptationModifier<A>(adaptor: adaptor, active: enabled))
    }
    
}

struct PresentationAdaptationModifier<A: Adaptable> where A.Source: Equatable {
    
    let adaptor: A
    let active: Bool
    
    @State private var values: [PresentationValue<A.Destination>] = []
    
}

extension PresentationAdaptationModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        let adaptor = PresentationValueMetaAdaptor(adaptor)
        content
            .presentationHandler(active: active){ values = $0.map{ adaptor($0) } }
            .preference(
                key: PresentationKey<A.Destination>.self,
                value: active ? values : []
            )
    }
    
}
