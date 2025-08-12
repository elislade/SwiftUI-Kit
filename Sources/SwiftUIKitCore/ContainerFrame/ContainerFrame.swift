import SwiftUI


public extension View {
    
    nonisolated func containerFrameContext() -> some View {
        backgroundPreferenceValue(ContainerFramePreferenceKey.self){ prefs in
            GeometryReader{ proxy in
                Color.clear.onChangePolyfill(of: proxy.size, initial: true){
                    prefs.forEach { $0(proxy.size) }
                }.onChangePolyfill(of: prefs.count, initial: true){
                    prefs.forEach { $0(proxy.size) }
                }
            }
        }
    }
    
    nonisolated func containerRelativeFramePolyfill(_ axes: Axis.Set, alignment: Alignment = .center) -> some View {
        modifier(RelativeFrameModifier(axes: axes, alignment: alignment))
    }
    
}


struct RelativeFrameModifier: ViewModifier {
    
    @State private var size = CGSize([10,10])
    
    let axes: Axis.Set
    let alignment: Alignment
    
    func body(content: Content) -> some View {
        content.frame(
            maxWidth: axes.contains(.horizontal) ? size.width : nil,
            maxHeight: axes.contains(.vertical) ? size.height : nil,
            alignment: alignment
        )
        .background {
            if !axes.isEmpty {
                Color.clear.preference(key: ContainerFramePreferenceKey.self, value: [{
                    self.size = $0
                }])
            }
        }
    }
    
}


struct ContainerFramePreferenceKey: PreferenceKey {
    static var defaultValue: [(CGSize) -> Void] { [] }
    
    static func reduce(value: inout [(CGSize) -> Void], nextValue: () -> [(CGSize) -> Void]) {
        value.append(contentsOf: nextValue())
    }
    
}
