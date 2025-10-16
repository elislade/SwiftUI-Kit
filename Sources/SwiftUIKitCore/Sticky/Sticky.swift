import SwiftUI

extension View {
    
    
    /// Defines the `StickyContext` for which children will stick to.
    /// - Parameter grouping : The grouping behaviour to use for views that don't have special behaviour defined. Defaults to ``StickyGrouping/displaced``
    /// - Returns: A view that calculates sticky offsets for its participating children.
    nonisolated public func stickyContext() -> some View {
        modifier(StickyContext())
    }
    
    
    /// Sticks this view to the bounds of the first parent ``SwiftUI/View/stickyContext(grouping:)`` with given insets. If inset is nil it will not stick.
    ///
    /// - Note: Sticky modifiers do not work with lazy views once it's removed off screen. Use `PinnedScrollableViews/sectionHeaders` and `PinnedScrollableViews/sectionFooters` for SwiftUI `LazyStack` and `LazyGrid` layouts.
    ///
    /// - Parameters:
    ///   - top : The top inset relative to its `StickyContext` bounds when the sticking should start taking place. Defaults to `nil`.
    ///   - bottom: The bottom inset relative to its `StickyContext` bounds when the sticking should start taking place. Defaults to `nil`.
    ///   - leading: The leading inset relative to its `StickyContext` bounds when the sticking should start taking place. Defaults to `nil`.
    ///   - trailing: The trailing relative to its `StickyContext` bounds when the sticking should start taking place. Defaults to `nil`.
    ///   - categoryMask: A category mask indicating other views to account for. Defaults to `.none`. This means no mask, so all views will account for all other views while sticking. This mask will be scoped to its `StickyContext` and will not account for views in another context even if they share the same mask.
    ///   - stateDidChange: A closure that gets called every time the sticking state changes for this view. Defaults to an empty closure.
    ///
    /// - Returns: A view that will stick to its `StickyContext`.
    nonisolated public func sticky(
        top: Double? = nil,
        bottom: Double? = nil,
        leading: Double? = nil,
        trailing: Double? = nil,
        categoryMask: StickyCategoryMask = .none,
        stateDidChange: @escaping (StickingState) -> Void = { _ in }
    ) -> some View {
        modifier(StickyModifier(
            stickyInsets: .init(
                top: top,
                bottom: bottom,
                leading: leading,
                trailing: trailing
            ),
            category: categoryMask,
            onChange: stateDidChange
        ))
    }
    
    
    /// Sticks this view to the bounds of the first parent ``SwiftUI/View/stickyContext(grouping:)`` with given edge set. If the edge set is empty it will not stick.
    ///
    /// - Note: Sticky modifiers do not work with lazy views once its removed off screen. Use `PinnedScrollableViews/sectionHeaders` and `PinnedScrollableViews/sectionFooters` for SwiftUI `LazyStack` and `LazyGrid` layouts.
    ///
    /// - Parameters:
    ///   - edges : A set of edges that this view should stick to the `StickyContext`.
    ///   - inset: The amount that should be inset from the edges relative to the `StickyContext` bounds. Defaults to 0.
    ///   - categoryMask: A category mask indicating other views to account for. Defaults to `.none`. This means no mask, so all views will account for all other views while sticking. This mask will be scoped to its `StickyContext` and will not account for views in another context even if they share the same mask.
    ///   - stateDidChange: A closure that gets called every time the sticking state changes for this view. Defaults to an empty closure.
    ///
    /// - Returns: A view that will stick to its `StickyContext`.
    nonisolated public func sticky(
        edges: Edge.Set,
        inset: Double = 0,
        categoryMask: StickyCategoryMask = .none,
        stateDidChange: @escaping (StickingState) -> Void = { _ in }
    ) -> some View {
        modifier(StickyModifier(
            stickyInsets: .init(
                top: edges.contains(.top) ? inset : nil,
                bottom: edges.contains(.bottom) ? inset : nil,
                leading: edges.contains(.leading) ? inset : nil,
                trailing: edges.contains(.trailing) ? inset : nil
            ),
            category: categoryMask,
            onChange: stateDidChange
        ))
    }
    
    
    /// Defines the ``StickyGrouping`` for all child views.
    /// - Parameter grouping : The``StickyGrouping``  to use. Defaults to ``StickyGrouping/displaced``
    /// - Returns: A modified view.
    nonisolated public func stickyGrouping(_ grouping: StickyGrouping) -> some View {
        environment(\.stickyGrouping, grouping)
    }
    
    
}



extension EnvironmentValues {
    
    @Entry var stickyGrouping: StickyGrouping = .displaced
    
}
