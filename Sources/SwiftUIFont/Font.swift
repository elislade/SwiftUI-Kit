import SwiftUI
import SwiftUIKitCore

public extension Font {
    
    subscript(weight: Font.Weight) -> Font {
        self.weight(weight)
    }
    
    subscript(leading: Font.Leading) -> Font {
        self.leading(leading)
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    subscript(width: Font.Width) -> Font {
        self.width(width)
    }
    
}


extension Font.Design: @retroactive Identifiable {
    public var id: Int { codableValue }
}


extension Font.TextStyle: @retroactive Identifiable {
    public var id: Int { codableValue }
}


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
        InlineEnvironmentValuesReader{ env in
            let r = resource ?? env.fontResource
            font(r.resolve(with: env.fontParameters.copy(replacing: key, with: value), in: env).opaqueFont)
        }
    }
    
    func resolveFont(_ resource: FontResource? = nil, with parameters: FontParameters? = nil) -> some View {
        InlineEnvironmentValuesReader{ env in
            let r = resource ?? env.fontResource
            let p = parameters ?? env.fontParameters
            font(r.resolve(with: p, in: env).opaqueFont)
        }
    }
    
    func font(_ parameters: FontParameters) -> some View {
        InlineEnvironmentValuesReader{ env in
            font(env.fontResource.resolve(with: parameters, in: env).opaqueFont)
        }
    }
    
    func font(_ resource: FontResource, modifier: @escaping (FontParameters) -> FontParameters = { $0 }) -> some View {
        InlineEnvironmentValuesReader{ env in
            font(resource.resolve(
                with: modifier(env.fontParameters),
                in: env
            ).opaqueFont)
        }
    }
    
}
