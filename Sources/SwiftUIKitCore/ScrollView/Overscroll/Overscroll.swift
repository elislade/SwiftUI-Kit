import SwiftUI


public extension View {
    
    /// A group that collects a set of elements and focuses the closest one for progress.
    /// - Returns: A modifed view.
    func overscrollGroup() -> some View {
        modifier(OverscrollGroupModifier())
    }
    
    /// Defines an element that accepts overscroll progress.
    /// - Parameter action: A closure that receives progress from 0 to 1.
    /// - Returns: A modified view.
    func onOverscroll(perform action: @escaping (Double) -> Void) -> some View {
        modifier(OverscrollElementModifier(action: action))
    }
    
    
    /// Offsets the view in the opposite direction of overscroll to give the effect of being pinned.
    /// - Note: Overscroll is the total amount of scroll past the usual scroll bounds of the content.
    /// - Returns: A modified view.
    func overscrollPinned(axis: Axis) -> some View {
        modifier(OverscrollPinnedModifier(axis: axis))
    }
    
}
