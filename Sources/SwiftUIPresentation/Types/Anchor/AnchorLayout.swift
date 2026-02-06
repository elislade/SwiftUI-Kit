import SwiftUI
import SwiftUIKitCore

public struct AnchorLayout: Layout {
    
    let type: PresentedAnchorType
    
    /// Init instance
    /// - Parameters:
    ///   - type: The primary anchor type for all subview layouts.
    public init(type: PresentedAnchorType) {
        self.type = type
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions(by: .zero)
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let dir = subviews.layoutDirection
        var anchorType: PresentedAnchorType = self.type
        
        for view in subviews {
            guard let sourceFrame = view[AnchorLayoutSourceKey.self] else { continue }
            let padding = view[AnchorLayoutPaddingKey.self]
            let alignMode = view[AnchorLayoutAlignmentKey.self]
            
            let source = CGRect(
                origin: sourceFrame.origin.adapt(to: dir, in: bounds.width),
                size: sourceFrame.size
            )
            
            if let new = view[AnchorLayoutLeaderKey.self] {
                anchorType = new
            }
            
            let viewSize = view.sizeThatFits(.unspecified)

            let cutoff: CGPoint = {
                let bufferSize = view[AnchorLayoutDestinationBufferKey.self]
                let viewSize = CGSizeMake(viewSize.width + bufferSize.width, viewSize.height + bufferSize.height)
                switch alignMode {
                case .keepUntilInvalid:
                    let cutoffX = dir == .leftToRight ? bounds.maxX - bounds.minX - viewSize.width - padding : bounds.maxX - bounds.minX - viewSize.width + source.width - padding
                    let cutoffY = bounds.maxY - bounds.minY - viewSize.height - source.height - padding
                    return .init(x: cutoffX, y: cutoffY)
                case .keepUntilPast(let anchor):
                    return .init(x: bounds.width * anchor.x, y: bounds.height * anchor.y)
                }
            }()

            let anchors = anchorType.anchors(
                with: source,
                cutoff: cutoff,
                layout: dir
            )
            
            view[AnchorLayoutStateKey.self](anchors)
            
            let sourceOffset = CGPoint(
                x: (source.width * anchors.source.x) * dir.scaleFactor,
                y: source.height * anchors.source.y
            )
            
            let destOffset = CGPoint(
                x: -viewSize.width * anchors.presentation.x,
                y: -viewSize.height * anchors.presentation.y
            )
            
            var xPadding: Double = 0
            var yPadding: Double = 0
            
            if let edge = anchors.horizontalEdge {
                switch edge {
                case .leading: xPadding = padding * dir.scaleFactor
                case .trailing: xPadding = -padding * dir.scaleFactor
                }
            }
            
            if let edge = anchors.verticalEdge {
                switch edge {
                case .top: yPadding = padding
                case .bottom: yPadding = -padding
                }
            }
            
            let origin = source.origin
                .translate(by: sourceOffset)
                .translate(by: destOffset)
                .translate(by: CGPoint(x: bounds.minX, y: bounds.minY))
                .translate(by: CGPoint(x: xPadding, y: yPadding))
            
            let safeOrigin = CGPoint(
                x: max(min(origin.x, (bounds.maxX - viewSize.width - padding)), bounds.minX + padding),
                y: max(min(origin.y, (bounds.maxY - viewSize.height - padding)), bounds.minY + padding)
            )
            
            view.place(
                at: safeOrigin,
                anchor: .topLeading,
                proposal: .unspecified
            )
        }
    }
    
}

struct AnchorLayoutPaddingKey: LayoutValueKey {
    
    static var defaultValue: Double { 2 }
    
}

struct AnchorLayoutDestinationBufferKey: LayoutValueKey {
    
    static var defaultValue: CGSize { .zero }
    
}

struct AnchorLayoutSourceKey: LayoutValueKey {
    
    static var defaultValue: CGRect? { nil }
    
}

struct AnchorLayoutLeaderKey: LayoutValueKey {
    
    static var defaultValue: PresentedAnchorType? { nil }
    
}

struct AnchorLayoutAlignmentKey: LayoutValueKey {
    
    static var defaultValue: AnchorAlignmentMode { .keepUntilInvalid }
    
}


struct AnchorLayoutStateKey: LayoutValueKey {
    
    static var defaultValue: (AnchorState) -> Void { { _ in } }
    
}

extension EnvironmentValues {
    
    @Entry public var anchorState: AnchorState? = nil
    
}

extension View {
    
    /// Adds a known amount of size that can contribute to layout size before its part of the view graph.
    /// - Note: You may want to use when an async operation can change element visibility affecting alignment thresholds but don't want to place an empty view placeholder.
    /// - Parameters:
    ///   - axis: The axis to apply the buffered size to.
    ///   - size: The size to add.
    /// - Returns: A modified view.
    nonisolated public func anchorLayoutBuffer(_ axis: Axis, size: Double) -> some View {
        layoutValue(
            key: AnchorLayoutDestinationBufferKey.self,
            value: .init(
                width: axis == .horizontal ? size : 0,
                height: axis == .vertical ? size : 0
            )
        )
    }
    
    nonisolated public func anchorLayoutBuffer(_ size: CGSize) -> some View {
        layoutValue(
            key: AnchorLayoutDestinationBufferKey.self,
            value: size
        )
    }
    
    /// Set an anchor source from where to anchor from.
    /// - Note: The `rect` needs to be resolved in the same coordinate system as the enclosing layout.
    /// Anchor preferences will not work, as the current implementation of `AnchorLayout` has no reference to a `GeometryProxy`.
    /// - Parameter rect: A `CGRect` of the source from the `AnchorLayout`s point of view.
    /// - Returns: A modified view.
    nonisolated public func anchorLayoutSourceFrame(_ rect: CGRect) -> some View {
        layoutValue(key: AnchorLayoutSourceKey.self, value: rect)
    }
    
    
    /// Establishes anchor layout type for all following elements that are not also providing a leader layout.
    /// - Parameters:
    ///   - type: The `PresentedAnchorType` to use.
    ///   - enabled: `Bool` indicating if this value is used or not. Defaults to `true`.
    /// - Returns: A modified view.
    nonisolated public func anchorLayoutLeader(_ type: PresentedAnchorType, enabled: Bool = true) -> some View {
        layoutValue(key: AnchorLayoutLeaderKey.self, value: enabled ? type : nil)
    }
    
    
    /// A closure that accepts what the resolved `AnchorState` will be, right before placing the view for layout.
    /// - Parameter action: A closure that gets called with `AnchorState`.
    /// - Returns: A modified view.
    nonisolated public func anchorLayoutState(_ action: @MainActor @escaping (AnchorState) -> Void) -> some View {
        layoutValue(key: AnchorLayoutStateKey.self){s in Task{ @MainActor in action(s) } }
    }
    
    
    /// Adds padding between the edge of the source and presentation view.
    /// - Parameter amount: Points of paddind to add.
    /// - Returns: A modified view.
    nonisolated public func anchorLayoutPadding(_ amount: Double) -> some View {
        layoutValue(key: AnchorLayoutPaddingKey.self, value: amount)
    }
    
    
    nonisolated public func anchorLayoutAlignmentMode(_ mode: AnchorAlignmentMode) -> some View {
        layoutValue(key: AnchorLayoutAlignmentKey.self, value: mode)
    }
    
}


extension CGPoint {
    
    func adapt(to layout: LayoutDirection, in container: CGFloat) -> CGPoint {
        layout == .leftToRight ? self : .init(x: container - x, y: y)
    }
    
}


extension PresentedAnchorType {
    
    var isHorizontal: Bool {
        guard case .horizontal = self else { return false }
        return true
    }
    
    var isVertical: Bool {
        guard case .vertical = self else { return false }
        return true
    }
    
    nonisolated func anchors(with sourceFrame: CGRect, cutoff: CGPoint, layout: LayoutDirection) -> AnchorState {
        switch self {
        case let .explicit(source, destination):
            return .init(source.invert(layout == .rightToLeft ? .horizontal : []), destination)
        case let .vertical(preferredAlignment):
            return auto(axis: .vertical, alignment: .init(horizontal: preferredAlignment, vertical: .center))
        case let .horizontal(preferredAlignment):
            return auto(axis: .horizontal, alignment: .init(horizontal: .center, vertical: preferredAlignment))
        }
        
        func auto(axis: Axis, alignment: Alignment = .center) -> AnchorState {
            var sourceResult = UnitPoint.center
            var destResult = UnitPoint.center
            let compareType = layout == .leftToRight ? CompareType.lessThan : .greaterThan
            
            switch axis {
            case .horizontal:
                if compare(sourceFrame.midX, compareType, cutoff.x) {
                    // source should be placed on leading and destination on trailing.
                    sourceResult.x = 1
                    destResult.x = 0
                } else {
                    sourceResult.x = 0
                    destResult.x = 1
                }
                
                if alignment.vertical == .top {
                    sourceResult.y = 0
                    destResult.y = 0
                } else if alignment.vertical == .bottom {
                    sourceResult.y = 1
                    destResult.y = 1
                }
                
                return .init(sourceResult, destResult.invert(layout == .leftToRight ? [] : .horizontal))
            case .vertical:
                if sourceFrame.minY < cutoff.y {
                    // source should be placed on top and destination on bottom.
                    sourceResult.y = 1
                    destResult.y = 0
                } else {
                    sourceResult.y = 0
                    destResult.y = 1
                }
                
                let a = UnitPoint(alignment)//.invert(layout == .leftToRight ? [] : .horizontal)
                
                if a.x == 0 {
                    sourceResult.x = 0
                    destResult.x = 0
                } else if a.x == 1 {
                    sourceResult.x = 1
                    destResult.x = 1
                }
                
                return .init(sourceResult.invert(layout == .leftToRight ? [] : .horizontal), destResult)
            }
        }
    }
    
    
}


struct LayoutPaddingPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGSize { .zero }
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        value.width += next.width
        value.height += next.height
    }
    
}

extension View {
    
    // Applies padding to the layout calculations only and has no impact on actual rendered padding.
    nonisolated public func preferredLayoutSizePadding(_ size: CGSize) -> some View {
        preference(key: LayoutPaddingPreferenceKey.self, value: size)
    }
    
    nonisolated public func preferredLayoutSizePadding(_ axes: Axis.Set, _ amount: Double) -> some View {
        preference(
            key: LayoutPaddingPreferenceKey.self,
            value: .init(
                width: axes.contains(.horizontal) ? amount : 0,
                height: axes.contains(.vertical) ? amount : 0
            )
        )
    }
    
}


struct ContainerLayoutSizePadding {
    
    @State private var padding = CGSize.zero
    
}


extension ContainerLayoutSizePadding: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .anchorLayoutBuffer(padding)
            .preferenceChangeConsumer(LayoutPaddingPreferenceKey.self){
                padding = $0
            }
    }
    
}


extension View {
    
    nonisolated public func anchorLayoutPaddingContainer() -> some View {
        modifier(ContainerLayoutSizePadding())
    }
    
}
