import SwiftUI

struct BoundsReaderModifier: ViewModifier {
    
    var sizeBinding: Binding<CGSize>?
    var rectBinding: Binding<CGRect>?
    var coordinateSpace: CoordinateSpace = .global
    
    func body(content: Content) -> some View {
        content
            .onDisappear {
                //sizeBinding?.wrappedValue = .zero
                //rectBinding?.wrappedValue = .zero
            }
            .overlay {
                GeometryReader{ proxy in
                    if let rectBinding {
                        Color.clear
                            .onChangePolyfill(of: proxy.frame(in: coordinateSpace).rounded(.toNearestOrEven), initial: true){
                                rectBinding.wrappedValue = proxy.frame(in: coordinateSpace).rounded(.toNearestOrEven)
                            }
                    } else if let sizeBinding {
                        Color.clear
                            .onChangePolyfill(of: proxy.size.rounded(.toNearestOrEven), initial: true){
                                sizeBinding.wrappedValue = proxy.size.rounded(.toNearestOrEven)
                            }
                    }
                    
                }
                .hidden()
            }
    }
    
}


public extension View {
    
    
    /// - Warning: Don't use resulting rect to change the bounds of the view being read or else it may cause an infinite layout loop.
    /// - Parameter readingToSize: A Binding to a CGSize that the bounds will be read to.
    /// - Returns: A view that reads its size to a binding.
    func boundsReader(readingToSize sizeBinding: Binding<CGSize>) -> some View {
        modifier(BoundsReaderModifier(sizeBinding: sizeBinding))
    }
    
    
    /// - Warning: Don't use resulting rect to change the bounds of the view being read or else it may cause an infinite layout loop.
    /// - Parameters:
    ///   - readingToRect: A Binding to a CGRect that the bounds will be read to.
    ///   - coordinateSpace: The coordinate space to read the bounds relative to. Defaults to global.
    /// - Returns: A view that reads its bounds to a binding.
    func boundsReader(readingToRect rectBinding: Binding<CGRect>, in coordinateSpace: CoordinateSpace = .global) -> some View {
        modifier(BoundsReaderModifier(rectBinding: rectBinding, coordinateSpace: coordinateSpace))
    }
    
    
}
