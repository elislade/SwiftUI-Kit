import SwiftUI


public extension View {
    
    @ViewBuilder func symbolEffectBounce(value: Bool, grouping: SymbolEffectGrouping = .whole, direction: SymbolEffectDirection = .up) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            symbolEffect(.bounce[grouping][direction], value: value)
        } else {
            self
        }
    }
    
    @ViewBuilder func symbolEffectPulse(value: Bool, grouping: SymbolEffectGrouping = .whole) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            symbolEffect(.pulse[grouping], value: value)
        } else {
            self
        }
    }
    
    @ViewBuilder func symbolEffectVariableColor(
        value: Bool,
        inactiveBehaviour: SymbolEffectInactiveLayerBehaviour = .hide,
        successiveBehaviour: SymbolEffectSucessiveVariableBehaviour = .cumulative
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            symbolEffect(.variableColor[inactiveBehaviour][successiveBehaviour], value: value)
        } else {
            self
        }
    }
   
    @ViewBuilder func symbolEffectScale(grouping: SymbolEffectGrouping = .whole, direction: SymbolEffectDirection = .up) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            symbolEffect(.scale[grouping][direction])
        } else {
            self
        }
    }
    
    @ViewBuilder func symbolEffectsRemovedPolyfill(_ isEnabled: Bool = true) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            symbolEffectsRemoved(isEnabled)
        } else {
            self
        }
    }
    
}
