import SwiftUI


public extension View {
    
    @ViewBuilder nonisolated func symbolEffectBounce<V: Equatable>(
        value: V,
        grouping: SymbolEffectGrouping = .whole,
        direction: SymbolEffectDirection = .up
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            symbolEffect(.bounce[grouping][direction], value: value)
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated func symbolEffectPulse<V: Equatable>(value: V, grouping: SymbolEffectGrouping = .whole) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            symbolEffect(.pulse[grouping], value: value)
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated func symbolEffectVariableColor<V: Equatable>(
        value: V,
        inactiveBehaviour: SymbolEffectInactiveLayerBehaviour = .hide,
        successiveBehaviour: SymbolEffectSucessiveVariableBehaviour = .cumulative
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            symbolEffect(.variableColor[inactiveBehaviour][successiveBehaviour], value: value)
        } else {
            self
        }
    }
   
    @ViewBuilder nonisolated func symbolEffectScale(grouping: SymbolEffectGrouping = .whole, direction: SymbolEffectDirection = .up) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            symbolEffect(.scale[grouping][direction])
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated func symbolEffectWiggle<V: Equatable>(
        value: V,
        grouping: SymbolEffectGrouping = .whole,
        direction: SymbolEffectDirection = .up,
        rotationDirection: SymbolEffectRotationDirection = .clockwise
    ) -> some View {
        if #available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
            symbolEffect(.wiggle[grouping][direction][rotationDirection], value: value)
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated func symbolEffectRotate<V: Equatable>(
        value: V,
        grouping: SymbolEffectGrouping = .whole,
        direction: SymbolEffectRotationDirection = .clockwise
    ) -> some View {
        if #available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
            symbolEffect(.rotate[grouping][direction], value: value)
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated func symbolEffectBreathe<V: Equatable>(value: V, grouping: SymbolEffectGrouping = .whole) -> some View {
        if #available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
            symbolEffect(.breathe[grouping], value: value)
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated func symbolEffectsRemovedPolyfill(_ isEnabled: Bool = true) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            symbolEffectsRemoved(isEnabled)
        } else {
            self
        }
    }
    
}
