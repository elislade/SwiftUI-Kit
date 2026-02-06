import SwiftUI
import SwiftUIKitCore


struct PresentationValuePresenter<Value: ValuePresentable, Metadata, Presentation: View> {
    
    @Environment(\.presentationIdentityBehaviour) private var behaviour
    
    @State private var builtValue: Value.Presented?
    @State private var stableID = UniqueID()
    @State private var customID: UniqueID?
    @State private var wasHidden = false
    
    @Binding private var value: Value
  
    private let environment: MainActorClosureKeyPath<EnvironmentValues>
    private let updatesOnBoundsChange: Bool
    private let metadata: Metadata
    private let presentation: @MainActor (Value.Presented) -> Presentation
    
    init(
        environment: MainActorClosureKeyPath<EnvironmentValues>,
        updatesOnBoundsChange: Bool = false,
        value: Binding<Value>,
        metadata: Metadata,
        @ViewBuilder presentation: @MainActor @escaping (Value.Presented) -> Presentation
    ){
        self.environment = environment
        self.updatesOnBoundsChange = updatesOnBoundsChange
        self.metadata = metadata
        self.presentation = presentation
        self._value = value
    }
    
    private var id: UniqueID {
        behaviour.isStable ? stableID : customID ?? .init()
    }
    
}

extension PresentationValuePresenter: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .onDisappear{ wasHidden = true }
            .onChangePolyfill(of: value.isPresented, initial: true){
                guard !wasHidden else { wasHidden = false; return }
 
                if value.isPresented {
                    stableID = UniqueID()
                    builtValue = value.unsafePresentedValue
                }
            }
            .overlay {
                if let builtValue {
                    Color.clear.anchorPreference(key: PresentationKey.self, value: .bounds){ anchor in
                        let id = id
                        return [.init(
                            id: id,
                            metadata: metadata,
                            anchor: anchor,
                            includeAnchorInEquatance: updatesOnBoundsChange,
                            view: presentation(builtValue)
                                .routeRelay()
                                .environment(\.parent, environment)
                                .onDisappear{
                                    guard !value.isPresented else { return }
                                    self.builtValue = nil
                                },
                            wantsDisposal: !value.isPresented,
                            dispose: {
                                // Only dismiss if this disposal is still relavent to the one presented
                                // This can happen when presenting and dismissing many times before this gets a chance to be called after its transition.
                                guard self.id == id else { return }
                                value.dismiss()
                            },
                            environment: environment
                        )]
                    }
                }
            }
            .onChangePolyfill(of: behaviour.customHashable){
                customID = behaviour.customHashable == nil ? nil : .init()
            }
    }
    
}

public protocol ValuePresentable: Hashable & Sendable {
    
    associatedtype Presented: Sendable
    
    /// - Warning: Do not access if`isPresented` is `false` as it will return an undefined value or crash.
    var unsafePresentedValue: Presented { get }
    
    var isPresented: Bool { get }
    
    mutating func dismiss()
    
}


extension Optional: ValuePresentable where Wrapped: Hashable {
    
    public var unsafePresentedValue: Wrapped { self! }
    
    public var isPresented: Bool { self != nil }
    
    public mutating func dismiss() {
        self = nil
    }
    
}


extension Bool: ValuePresentable {
    
    public var unsafePresentedValue: Bool { self }
    public var isPresented: Bool { self }
    
    public mutating func dismiss() {
        self = false
    }
    
}
