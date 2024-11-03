import SwiftUI
import SwiftUIKitCore


/// A `VStack` that will adapt to the `LayoutDirectionSuggestion` EnvironmentValue.
public struct LayoutSuggestableVStack<Content: View>: View {
    
    @Environment(\.layoutDirectionSuggestion) private var layoutSuggestion
    
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    let content: () -> Content
    
    /// Creates an instance with the given spacing and horizontal alignment.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the subviews in this stack. This
    ///     guide has the same vertical screen coordinate for every subview.
    ///   - spacing: The distance between adjacent subviews, or `nil` if you
    ///     want the stack to choose a default distance for each pair of
    ///     subviews.
    ///   - content: A view builder that creates the content of this stack.
    public init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    private var layout: AnyLayout {
        if layoutSuggestion == .useBottomToTop {
            AnyLayout(ReversedVStackLayout(alignment: alignment, spacing: spacing))
        } else {
            AnyLayout(VStackLayout(alignment: alignment, spacing: spacing))
        }
    }
    
    public var body: some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            layout{ content() }
        } else {
            VStack(alignment: alignment, spacing: spacing){
                content()
                    .scaleEffect(y: layoutSuggestion == .useBottomToTop ? -1 : 1)
            }
            .scaleEffect(y: layoutSuggestion == .useBottomToTop ? -1 : 1)
        }
    }
    
}
