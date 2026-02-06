import SwiftUI


struct SafeAreaChangeModifier {
    
    let regions: SafeAreaRegions
    let action: (EdgeInsets) -> Void
    
    func body(content: Content) -> some View {
        content.background{
            GeometryReader { proxy in
                let insets = proxy.safeAreaInsets
                Color.clear.onChangePolyfill(of: insets, initial: true){
                    action(insets)
                }
            }
            .ignoresSafeArea(.all.subtracting(regions))
        }
    }
    
}

extension SafeAreaChangeModifier: ViewModifier { }

extension View {
    
    nonisolated public func onSafeAreaChange(_ regions: SafeAreaRegions = .all, peform action: @escaping (EdgeInsets) -> Void) -> some View {
        modifier(SafeAreaChangeModifier(regions: regions, action: action))
    }
    
}
