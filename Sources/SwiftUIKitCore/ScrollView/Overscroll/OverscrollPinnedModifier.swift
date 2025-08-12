import SwiftUI
import Combine


struct OverscrollPinnedModifier {

    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.verticalOverscrollCompensation) private var overscrollV
    @Environment(\.horizontalOverscrollCompensation) private var overscrollH
    @State private var compensation: CGFloat = 0
    
    let axis: Axis
    
    private var overscroll: AnyPublisher<CGFloat, Never>? {
        switch axis {
        case .vertical: overscrollV
        case .horizontal: overscrollH
        @unknown default: nil
        }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: axis == .horizontal ? compensation * layoutDirection.scaleFactor : 0,
                y: axis == .vertical ? compensation : 0
            )
            .background{
                if let overscroll {
                    Color.clear.onReceive(overscroll){ val in
                        compensation = val
                    }
                }
            }
    }
    
}

extension OverscrollPinnedModifier: ViewModifier {}
