import SwiftUI


extension View {
    
    @ViewBuilder nonisolated public func symbolEffectDrawOnIfAvailable(
        grouping: SymbolEffectGrouping = .whole,
        isActive: Bool = true
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            symbolEffect(.drawOn, isActive: isActive)
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated public func symbolEffectDrawOffIfAvailable(
        grouping: SymbolEffectGrouping = .whole,
        isActive: Bool = true
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            symbolEffect(.drawOff, isActive: isActive)
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated public func symbolEffectBounceIfAvailable<V: Equatable>(
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
    
    @ViewBuilder nonisolated public func symbolEffectPulseIfAvailable<V: Equatable>(value: V, grouping: SymbolEffectGrouping = .whole) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            symbolEffect(.pulse[grouping], value: value)
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated public func symbolEffectVariableColorIfAvailable<V: Equatable>(
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
   
    @ViewBuilder nonisolated public func symbolEffectScaleIfAvailable(grouping: SymbolEffectGrouping = .whole, direction: SymbolEffectDirection = .up, isActive: Bool = true) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            symbolEffect(.scale[grouping][direction], isActive: isActive)
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated public func symbolEffectWiggleIfAvailable<V: Equatable>(
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
    
    @ViewBuilder nonisolated public func symbolEffectRotateIfAvailable<V: Equatable>(
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
    
    @ViewBuilder nonisolated public func symbolEffectBreatheIfAvailable<V: Equatable>(value: V, grouping: SymbolEffectGrouping = .whole) -> some View {
        if #available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
            symbolEffect(.breathe[grouping], value: value)
        } else {
            self
        }
    }
    
    @ViewBuilder nonisolated public func symbolEffectsRemovedIfAvailable(_ isEnabled: Bool = true) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            symbolEffectsRemoved(isEnabled)
        } else {
            self
        }
    }
    
}
