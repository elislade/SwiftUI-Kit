import SwiftUI
import SwiftUIKitCore

public protocol TransitionProvider {
    
    associatedtype TransitionModifier: ViewModifier
    
    func modifier(_ state: TransitionState) -> TransitionModifier
}


public enum TransitionState: Equatable {
    
    case identity
    case progress(_ value: Double)
    
    public var value: Double {
        switch self {
        case .identity: return 0
        case .progress(let v): return v
        }
    }
    
}


extension TransitionProvider {
    public func modifier(percent: Double) -> TransitionModifier {
        self.modifier(.progress(percent))
    }
    
    public var identity: TransitionModifier { modifier(.identity) }
}


public struct DefaultNavTransitionProvider: TransitionProvider {
    
    public init(){}

    public func modifier(_ state: TransitionState) -> some ViewModifier {
        DefaultNavTransitionModifier(state: state)
    }
    
}


public extension TransitionProvider where Self == DefaultNavTransitionProvider {
    
    static var `default`: DefaultNavTransitionProvider { DefaultNavTransitionProvider() }
    
}


struct DefaultNavTransitionModifier: ViewModifier {

    @Environment(\.reduceMotion) private var reduceMotion: Bool
    
    let state: TransitionState
    
    func body(content: Content) -> some View {
        content
            .overlay{
                Color.black
                    .opacity(state.value / 2)
                    .ignoresSafeArea()
            }
            .offset(x: reduceMotion ? 0 : state.value * -120)
    }
    
}
