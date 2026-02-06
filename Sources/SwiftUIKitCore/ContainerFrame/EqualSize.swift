import SwiftUI

struct EqualSizeElement {
    let isLeader: Bool
    let size: CGSize
    let callback: (CGSize) -> Void
}

struct EqualSizeElementPreferenceKey: PreferenceKey {
    
    static var defaultValue: [EqualSizeElement] { [] }
    
    static func reduce(value: inout [EqualSizeElement], nextValue: () -> [EqualSizeElement]) {
        value.append(contentsOf: nextValue())
    }
    
}


extension View {
    
    nonisolated public func equalSizeContext(_ sort: @escaping (CGSize, CGSize) -> Bool) -> some View {
        backgroundPreferenceValue(EqualSizeElementPreferenceKey.self){ prefs in
            let sorted = prefs.sorted(by: { sort($0.size, $1.size) })
            let leader = sorted.first(where: \.isLeader)
            let sizeToMatch = leader?.size ?? sorted.first?.size
            
            Color.clear.onChangePolyfill(of: sizeToMatch, initial: true){
                guard let sizeToMatch else { return }
                for element in sorted {
                    if element.size == sizeToMatch { continue }
                    element.callback(sizeToMatch)
                }
            }
        }
        .preferenceKeyReset(EqualSizeElementPreferenceKey.self)
    }
    
    nonisolated public func equalSizeLeader(isActive: Bool = true) -> some View {
        modifier(EqualSizeLeaderContent(isActive: isActive))
    }
    
    nonisolated public func equalSize(axes: Axis.Set, alignment: Alignment = .center) -> some View {
        modifier(EqualSizeElementContent(axes: axes, alignment: alignment))
    }
    
    nonisolated public func equalSizeDisabled(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.equalSizeAxesEnabled){ value in
            if disabled {
                value = []
            }
        }
    }
    
    nonisolated public func equalSizeDisabled(axes: Axis.Set) -> some View {
        transformEnvironment(\.equalSizeAxesEnabled){ value in
            value.subtract(axes)
        }
    }
    
}

extension EnvironmentValues {
    
    @Entry var equalSizeAxesEnabled: Axis.Set = [.horizontal, .vertical]
    
}


struct EqualSizeLeaderContent {
    
    @Environment(\.equalSizeAxesEnabled) private var enabledAxes
    
    private var isEnabled: Bool { !enabledAxes.isEmpty }
    
    let isActive: Bool
    
}

extension EqualSizeLeaderContent: ViewModifier {
    
    func body(content: Content) -> some View {
        content.background{
            if isEnabled && isActive {
                GeometryReader{ proxy in
                    Color.clear.preference(
                        key: EqualSizeElementPreferenceKey.self,
                        value: [.init(isLeader: true, size: proxy.size){ _ in }]
                    )
                }
            }
        }
    }
    
}


struct EqualSizeElementContent {
    
    @Environment(\.equalSizeAxesEnabled) private var enabledAxes
    
    @State private var width: CGFloat?
    @State private var height: CGFloat?
    @State private var constrained: Axis.Set = []
    
    private var isEnabled: Bool { !enabledAxes.isEmpty }
    
    let axes: Axis.Set
    let alignment: Alignment
    
}

extension EqualSizeElementContent: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .environment(\.containerConstrained, constrained)
            .background{
                if isEnabled && !axes.isEmpty {
                    GeometryReader{ proxy in
                        Color.clear.preference(
                            key: EqualSizeElementPreferenceKey.self,
                            value: [.init(isLeader: false, size: proxy.size){ size in
                                if axes.contains(.horizontal) && enabledAxes.contains(.horizontal) {
                                    width = size.width
                                } else {
                                    width = nil
                                }
                                
                                if axes.contains(.vertical) && enabledAxes.contains(.vertical) {
                                    height = size.height
                                } else {
                                    height = nil
                                }
                            }]
                        )
                    }
                    .onDisappear {
                        width = nil
                        height = nil
                    }
                }
            }
            .frame(
                width: width,
                height: height,
                alignment: alignment
            )
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
    }
    
}
