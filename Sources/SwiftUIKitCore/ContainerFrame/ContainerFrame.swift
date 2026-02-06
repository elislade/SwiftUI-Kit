import SwiftUI


extension View {
    
    nonisolated public func containerFrameContext() -> some View {
        backgroundPreferenceValue(ContainerFramePreferenceKey.self){ prefs in
            GeometryReader{ proxy in
                Color.clear.onChangePolyfill(of: proxy.size, initial: true){
                    prefs.forEach { $0(proxy.size) }
                }.onChangePolyfill(of: prefs.count, initial: true){
                    prefs.forEach { $0(proxy.size) }
                }
            }
        }
        .preferenceKeyReset(ContainerFramePreferenceKey.self)
    }
    
    nonisolated public func containerRelativeFramePolyfill(_ axes: Axis.Set, alignment: Alignment = .center) -> some View {
        modifier(RelativeFrameModifier(axes: axes, alignment: alignment))
    }
    
}

extension EnvironmentValues {
    
    @Entry public internal(set) var containerConstrained: Axis.Set = []
    
}

struct RelativeFrameModifier: ViewModifier {
    
    @State private var width: CGFloat?
    @State private var height: CGFloat?
    @State private var constrained: Axis.Set = []
    
    let axes: Axis.Set
    let alignment: Alignment
    
    func body(content: Content) -> some View {
        content.frame(
            maxWidth: axes.contains(.horizontal) ? width : nil,
            maxHeight: axes.contains(.vertical) ? height : nil,
            alignment: alignment
        )
        .environment(\.containerConstrained, constrained)
        .onChangePolyfill(of: width == nil){
            if width == nil {
                constrained.remove(.horizontal)
            } else {
                constrained.insert(.horizontal)
            }
        }
        .onChangePolyfill(of: height == nil){
            if height == nil {
                constrained.remove(.vertical)
            } else {
                constrained.insert(.vertical)
            }
        }
        .background {
            Color.clear.preference(key: ContainerFramePreferenceKey.self, value: [{
                if axes.contains(.horizontal){
                    width = $0.width
                } else {
                    width = nil
                }
                
                if axes.contains(.vertical){
                    height = $0.height
                } else {
                    height = nil
                }
            }])
        }
    }
    
}


struct ContainerFramePreferenceKey: PreferenceKey {
    static var defaultValue: [(CGSize) -> Void] { [] }
    
    static func reduce(value: inout [(CGSize) -> Void], nextValue: () -> [(CGSize) -> Void]) {
        value.append(contentsOf: nextValue())
    }
    
}
