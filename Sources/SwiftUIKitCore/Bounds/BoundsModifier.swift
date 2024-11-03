import SwiftUI

struct ChildBoundsModifier<V: View>: ViewModifier {
    
    enum Level {
        case overlay
        case background
    }
    
    let level: Level
    let tag: String
    var alignment: Alignment = .center
    @ViewBuilder let view: ([CGRect]) -> V
    
    private func levelContent(value: [TaggedBounds]) -> some View {
        GeometryReader { proxy in
           ZStack(alignment: alignment){
               Color.clear
               view(value.filter{ $0.tag == tag }.map{ proxy[$0.bounds] })
           }
        }
    }
    
    func body(content: Content) -> some View {
        switch level {
        case .overlay:
            content
                .overlayPreferenceValue(TaggedBoundsKey.self, alignment: alignment){ value in
                    levelContent(value: value)
                }
                .transformPreference(TaggedBoundsKey.self) { value in
                    value.removeAll(where: { $0.tag == tag })
                }
        case .background:
            content
                .backgroundPreferenceValue(TaggedBoundsKey.self, alignment: alignment){ value in
                    levelContent(value: value)
                }
                .transformPreference(TaggedBoundsKey.self) { value in
                    value.removeAll(where: { $0.tag == tag })
                }
        }
    }
    
}

struct TaggedBounds: Equatable, Sendable {
    
    let tag: String
    let bounds: Anchor<CGRect>
    
}

public struct BoundsPreferenceKey: PreferenceKey {
    public typealias Value = [Anchor<CGRect>]

    public static var defaultValue: Value = []

    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

struct TaggedBoundsKey: PreferenceKey {
    public typealias Value = [TaggedBounds]

    public static var defaultValue: Value = []

    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}
