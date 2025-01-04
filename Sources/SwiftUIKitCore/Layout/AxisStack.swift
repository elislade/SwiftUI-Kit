import SwiftUI

/// A view that arranges its subviews in a line along a given axis.
///
public struct AxisStack<Content: View>: View {
    
    let axis: Axis
    let alignment: Alignment
    let spacing: CGFloat?
    let isLazy: Bool
    let content: () -> Content
    
    /// - Parameters:
    ///   - axis: The axis for the stacks layout.
    ///   - alignment: The guide for aligning the subviews in this stack. This
    ///     guide has the same vertical screen coordinate for every subview.
    ///   - spacing: The distance between adjacent subviews, or `nil` if you
    ///     want the stack to choose a default distance for each pair of
    ///     subviews.
    ///   - isLazy: Bool indicating whether to use lazy stack. Defaults to false.
    ///   - content: A view builder that creates the content of this stack.
    public init(
        _ axis: Axis,
        alignment: Alignment = .center,
        spacing: CGFloat? = nil,
        isLazy: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.alignment = alignment
        self.spacing = spacing
        self.isLazy = isLazy
        self.content = content
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    private var layout: AnyLayout {
        switch axis {
        case .horizontal:
            AnyLayout(HStackLayout(alignment: alignment.vertical, spacing: spacing))
        case .vertical:
            AnyLayout(VStackLayout(alignment: alignment.horizontal, spacing: spacing))
        }
    }
    
    public var body: some View {
        if isLazy {
            switch axis {
            case .horizontal:
                LazyHStack(alignment: alignment.vertical, spacing: spacing, content: content)
            case .vertical:
                LazyVStack(alignment: alignment.horizontal, spacing: spacing, content: content)
            }
        } else {
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                layout { content() }
            } else {
                switch axis {
                case .horizontal:
                    HStack(alignment: alignment.vertical, spacing: spacing, content: content)
                case .vertical:
                    VStack(alignment: alignment.horizontal, spacing: spacing, content: content)
                }
            }
        }
    }
    
}
