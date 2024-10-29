import SwiftUI

public extension View {
    
    
    /// Tag this current views bounds to be caught by a parent view
    /// - Parameters:
    ///   - tag: A string value that you tag this views bounds with.
    ///   - active: A bool indicating whether to tag this views bounds or not. Defaults to true.
    /// - Returns: A view that tags this views bounds.
    func bounds(tag: String, active: Bool = true) -> some View {
        anchorPreference(
            key: TaggedBoundsKey.self,
            value: .bounds
        ){ active ? [ .init(tag: tag, bounds: $0) ] : [] }
    }
    
    
    /// A convenience that tags and catches its own bounds.
    /// Once catching a bounds change any parent will not have visibility into this tagged value.
    /// - Parameters:
    ///   - proxy: A proxy in which to resolve the bounds relative to.
    ///   - didChange: A callback that gets called every time this views bounds change.
    /// - Returns: A view that listens to bound changes.
    func boundsChange(in proxy: GeometryProxy, didChange: @escaping (CGRect) -> Void) -> some View {
        InlineState(UUID()){ id in
            bounds(tag: id.uuidString).childBoundsChange(tag: id.uuidString, in: proxy){
                didChange($0.first ?? .zero)
            }
        }
    }
    
    
    /// Once catching a bounds change any parent will not have visibility into this tagged value.
    /// - Parameters:
    ///   - tag: Tag to match with child views with the same tag.
    ///   - proxy: A `GeometryProxy` in which to resolve the bounds relative to.
    ///   - didChange: A callback that gets called every time this views bounds change.
    /// - Returns: A view that listens to bound changes.
    func childBoundsChange(tag: String, in proxy: GeometryProxy, didChange: @escaping ([CGRect]) -> Void) -> some View {
        onPreferenceChange(TaggedBoundsKey.self){ value in
            didChange(value.filter{ $0.tag == tag }.map{ proxy[$0.bounds] })
        }
        .transformPreference(TaggedBoundsKey.self) { value in
            value.removeAll(where: { $0.tag == tag })
        }
    }
    
    
    /// A convenience that tags and catches its own bounds.
    /// Once catching a bounds change any parent will not have visibility into this tagged value
    /// - Parameters:
    ///   - alignment: The alignment of the overlayed view. Defaults to center.
    ///   - content: A view builder that takes the rounds `CGRect` as an argument.
    /// - Returns: A view that listens to bound changes.
    func boundsOverlay<V: View>(alignment: Alignment = .center, @ViewBuilder content: @escaping (CGRect) -> V) -> some View {
        InlineState(UUID()){ id in
            bounds(tag: id.uuidString).childBoundsOverlay(tag: id.uuidString, alignment: alignment){
                content($0.first ?? .zero)
            }
        }
    }
    
    
    /// Once catching a bounds change any parent will not have visibility into this tagged value
    /// - Parameters:
    ///   - tag: Tag to match with child views with the same tag.
    ///   - alignment: The alignment of the overlayed view. Defaults to center.
    ///   - content: A view builder that takes an array of bounds that match the tag as input.
    /// - Returns: A view that listens to child bound changes.
    func childBoundsOverlay<V: View>(tag: String, alignment: Alignment = .center, @ViewBuilder content: @escaping ([CGRect]) -> V) -> some View {
        modifier(ChildBoundsModifier(
            level: .overlay,
            tag: tag,
            alignment: alignment,
            view: content
        ))
    }
    
    
    /// A convienence that tags and catches its own bounds.
    /// Once catching a bounds change any parent will not have visibility into this tagged value.
    /// - Parameters:
    ///   - alignment: The alignment of the background view. Defaults to center.
    ///   - content: A view builder that takes this views bounds as input.
    /// - Returns: A view that listens to bound changes.
    func boundsBackground<V: View>(alignment: Alignment = .center, @ViewBuilder content: @escaping (CGRect) -> V) -> some View {
        InlineState(UUID()){ id in
            bounds(tag: id.uuidString).childBoundsBackground(tag: id.uuidString, alignment: alignment){
                content($0.first ?? .zero)
            }
        }
    }
    
    
    /// Once catching a bounds change any parent will not have visibility into this tagged value.
    /// - Parameters:
    ///   - tag: Tag to match with child views with the same tag.
    ///   - alignment: The alignment of the background view. Defaults to center.
    ///   - content: A view builder that takes an array of bounds that match the tag as input.
    /// - Returns: A view that listens to bound changes.
    func childBoundsBackground<V: View>(tag: String, alignment: Alignment = .center, @ViewBuilder content: @escaping ([CGRect]) -> V) -> some View {
        modifier(ChildBoundsModifier(
            level: .background,
            tag: tag,
            alignment: alignment,
            view: content
        ))
    }
    
}


