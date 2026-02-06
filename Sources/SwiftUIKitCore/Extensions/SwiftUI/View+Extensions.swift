import SwiftUI


extension View {
    
    nonisolated public func maxWidthExpanding(_ value: Double) -> some View {
        frame(maxWidth: value).frame(maxWidth: .infinity)
    }
    
    @available(*, deprecated, renamed: "geometryGroupIfAvailable()")
    nonisolated public func geometryGroupPolyfill() -> some View {
        geometryGroupIfAvailable()
    }
    
    @ViewBuilder nonisolated public func geometryGroupIfAvailable() -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            geometryGroup()
        } else {
            self
        }
    }
    
    nonisolated public func offset(_ point: CGPoint) -> some View {
        offset(x: point.x, y: point.y)
    }
    
    nonisolated public func offset(_ simd: SIMD2<Double>) -> some View {
        offset(x: simd.x, y: simd.y)
    }
    
    nonisolated public func position(_ simd: SIMD2<Double>) -> some View {
        position(x: simd.x, y: simd.y)
    }
    
    nonisolated public func language(_ code: Locale.LanguageCode) -> some View {
        environment(\.locale, .init(languageComponents: .init(languageCode: code)))
            .environment(\.layoutDirection, .init(languageCode: code))
    }
    
}
