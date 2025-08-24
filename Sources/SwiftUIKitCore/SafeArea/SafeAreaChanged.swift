import SwiftUI


struct SafeAreaChangeModifier {
    
    let regions: SafeAreaRegions
    let action: (EdgeInsets) -> Void
    
    func body(content: Content) -> some View {
        content.background{
            GeometryReader { proxy in
                Color.clear.onChangePolyfill(of: proxy.safeAreaInsets, initial: true){
                    action(proxy.safeAreaInsets)
                }
            }
            .ignoresSafeArea(.all.subtracting(regions))
        }
    }
    
}

extension SafeAreaChangeModifier: ViewModifier { }

extension View {
    
    nonisolated func onSafeAreaChange(_ regions: SafeAreaRegions = .all, peform action: @escaping (EdgeInsets) -> Void) -> some View {
        modifier(SafeAreaChangeModifier(regions: regions, action: action))
    }
    
}
