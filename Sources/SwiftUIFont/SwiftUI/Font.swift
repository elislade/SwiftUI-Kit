import SwiftUI
import SwiftUIKitCore

public extension View {
    
    func fontResource(_ resource: FontResource?) -> some View {
        transformEnvironment(\.fontResource) { value in
            if let resource {
                value = resource
            }
        }
    }
    
    func resetFontParameters<V>(_ keys: WritableKeyPath<FontParameters, V>...) -> some View {
        transformEnvironment(\.fontParameters) { params in
            for key in keys {
                params[keyPath: key] = FontParameters.identity[keyPath: key]
            }
        }
    }
    
    func resetFontParameters(reset: Bool = true) -> some View {
        transformEnvironment(\.fontParameters) { params in
            if reset {
                params = .identity
            }
        }
    }
    
    func fontParameter<V>(_ key: WritableKeyPath<FontParameters, V>, value: V) -> some View {
        transformEnvironment(\.fontParameters) { params in
            params[keyPath: key] = value
        }
    }
    
    func fontParameters(_ newParams: FontParameters) -> some View {
        transformEnvironment(\.fontParameters) { params in
            params = newParams
        }
    }
 
    func resolveFont<V>(_ resource: FontResource? = nil, overriding key: WritableKeyPath<FontParameters, V>, value: V) -> some View {
        InlineEnvironmentValue(\.resolvedFont){ resolvedFont in
            font(resolvedFont.opaqueFont)
        }
        .transformEnvironment(\.fontResource){
            if let resource {
                $0 = resource
            }
        }
        .transformEnvironment(\.fontParameters){ params in
            params = params.copy(replacing: key, with: value)
        }
    }
    
    func resolveFont(_ resource: FontResource? = nil, with parameters: FontParameters? = nil) -> some View {
        InlineEnvironmentValue(\.resolvedFont){ resolvedFont in
            font(resolvedFont.opaqueFont)
        }
        .transformEnvironment(\.fontResource){
            if let resource {
                $0 = resource
            }
        }
        .transformEnvironment(\.fontParameters){
            if let parameters {
                $0 = parameters
            }
        }
    }
    
    func font(_ parameters: FontParameters) -> some View {
        InlineEnvironmentValue(\.resolvedFont){ resolvedFont in
            font(resolvedFont.opaqueFont)
        }
        .transformEnvironment(\.fontParameters){ $0 = parameters }
    }
    
    func font(_ resource: FontResource, modifier: @escaping (FontParameters) -> FontParameters = { $0 }) -> some View {
        InlineEnvironmentValue(\.resolvedFont){ font in
            self.font(font.opaqueFont)
        }
        .transformEnvironment(\.fontResource){ $0 = resource }
        .transformEnvironment(\.fontParameters){ $0 = modifier($0) }
    }
    
}
