import Symbols


public enum SymbolEffectSucessiveVariableBehaviour: Hashable, CaseIterable, Sendable, BitwiseCopyable {
    
    /// Animation applies its Cumulative variant, where each sucessive
    /// variable layer is enabled and stays enabled until the end of
    /// the animation cycle.
    case cumulative

    /// Animation applies its Iterative variant, where each sucessive
    /// variable layer is active for a short period of time and then
    /// inactive until the animation cycle repeats.
    case iterative

}


protocol SymbolSucessiveVariableBehaviourConformance {
    var cumulative: Self { get }
    var iterative: Self { get }
}


extension SymbolSucessiveVariableBehaviourConformance {
    
    nonisolated subscript(_ behaviour: SymbolEffectSucessiveVariableBehaviour) -> Self {
        switch behaviour {
        case .cumulative: cumulative
        case .iterative: iterative
        }
    }
    
}

public enum SymbolEffectInactiveLayerBehaviour: Hashable, CaseIterable, Sendable, BitwiseCopyable {
    case dim
    case hide
}

public enum SymbolEffectDirection: Hashable, CaseIterable, Sendable, BitwiseCopyable {
    case up
    case down
}

public enum SymbolEffectGrouping: Hashable, CaseIterable, Sendable, BitwiseCopyable {
    case byLayer
    case whole
}

protocol SymbolInactiveLayerBehaviourConformance {
    var hideInactiveLayers: Self { get }
    var dimInactiveLayers: Self { get }
}

extension SymbolInactiveLayerBehaviourConformance  {
    
    nonisolated subscript(_ behaviour: SymbolEffectInactiveLayerBehaviour) -> Self {
        switch behaviour {
        case .dim: dimInactiveLayers
        case .hide: hideInactiveLayers
        }
    }
    
}


protocol SymbolDirectionConformance {
    var up: Self { get }
    var down: Self { get }
}

extension SymbolDirectionConformance  {
    
    nonisolated subscript(_ direction: SymbolEffectDirection) -> Self {
        switch direction {
        case .up: up
        case .down: down
        }
    }
    
}

protocol SymbolGroupingConformance {
    var byLayer: Self { get }
    var wholeSymbol: Self { get }
}

extension SymbolGroupingConformance {
    
    nonisolated subscript(_ grouping: SymbolEffectGrouping) -> Self {
        switch grouping {
        case .byLayer: byLayer
        case .whole: wholeSymbol
        }
    }
    
}


@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension BounceSymbolEffect: SymbolGroupingConformance, SymbolDirectionConformance {}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension AppearSymbolEffect: SymbolGroupingConformance, SymbolDirectionConformance {}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DisappearSymbolEffect: SymbolGroupingConformance, SymbolDirectionConformance {}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension ReplaceSymbolEffect: SymbolGroupingConformance {}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension PulseSymbolEffect: SymbolGroupingConformance {}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension ScaleSymbolEffect: SymbolGroupingConformance, SymbolDirectionConformance {}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension VariableColorSymbolEffect: SymbolInactiveLayerBehaviourConformance, SymbolSucessiveVariableBehaviourConformance {}
