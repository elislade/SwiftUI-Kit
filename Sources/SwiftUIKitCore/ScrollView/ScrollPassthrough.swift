import SwiftUI
@preconcurrency import Combine


public extension View {
    
    /// Any views below this one will have shared access to all scroll passthrough events in any sibling or cousin branches.
    nonisolated func scrollPassthroughContext(enabled: Bool = true) -> some View {
        InlineState(ScrollPassthrough()){ passthrough in
            environment(\.scrollPassthrough, enabled ? passthrough : nil)
        }
    }
    
    
    /// Disables any scroll passthrough reading and writing to views below this one.
    nonisolated func scrollPassthroughDisabled(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.scrollPassthrough){ passthrough in
            if disabled {
                passthrough = nil
            }
        }
    }
    
}


public extension EnvironmentValues {
    
    @Entry var scrollPassthrough: ScrollPassthrough? = nil
    
    var scrollOffsetPassthrough: PassthroughSubject<CGPoint, Never>? {
        scrollPassthrough?.contentOffset
    }
    
    var verticalOverscrollCompensation: AnyPublisher<CGFloat, Never>? {
        scrollPassthrough?.verticalOverscrollCompensation
    }
    
    var horizontalOverscrollCompensation: AnyPublisher<CGFloat, Never>? {
        scrollPassthrough?.horizontalOverscrollCompensation
    }
    
}


public struct ScrollPassthrough {
    
    public let contentOffset = PassthroughSubject<CGPoint, Never>()
    public let contentSize = CurrentValueSubject<CGSize, Never>(.zero)
    public let size = CurrentValueSubject<CGSize, Never>(.zero)
    
    /// All outputs combined in the order of contentOffset, contentSize, and size.
    public var combined: AnyPublisher<(contentOffset: CGPoint, contentSize: CGSize, size: CGSize), Never> {
        contentOffset
            .combineLatest(contentSize, size)
            .map{ ($0, $1, $2) }
            .eraseToAnyPublisher()
    }
    
    public var verticalOverscrollCompensation: AnyPublisher<CGFloat, Never> {
        contentOffset
            .map(\.y)
            .combineLatest(
                contentSize.map(\.height),
                size.map(\.height)
            )
            .map{ offset, contentDimension, coordinateDimension in
                if offset > 0 {
                    return offset * -1
                }
                
                let insetFromEnd = (coordinateDimension - contentDimension)

                if offset < insetFromEnd {
                    return (offset - insetFromEnd) * -1
                }
                return 0
            }
            .eraseToAnyPublisher()
    }
    
    public var horizontalOverscrollCompensation: AnyPublisher<CGFloat, Never> {
        contentOffset
            .map(\.x)
            .combineLatest(
                contentSize.map(\.width),
                size.map(\.width)
            )
            .map{ offset, contentDimension, coordinateDimension in
                if offset > 0 {
                    return offset * -1
                }
                
                let insetFromEnd = (coordinateDimension - contentDimension)

                if offset < insetFromEnd {
                    return (offset - insetFromEnd) * -1
                }
                return 0
            }
            .eraseToAnyPublisher()
    }
    
}
