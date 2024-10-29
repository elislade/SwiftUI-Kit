import SwiftUI


public extension View {
    
    func navDestination<Value: Hashable, Destination: View>(
        for valueType: Value.Type,
        @ViewBuilder content: @escaping (Value) -> Destination
    ) -> some View {
        modifier(NavViewDestinationValueModifier(destination: content))
    }
    
    func navDestination<Element: Identifiable, Destination: View>(
        presentedElements: Binding<Array<Element>>,
        content: @escaping (Element) -> Destination
    ) -> some View {
        modifier(NavViewPresentingStackModifier(
            data: presentedElements,
            destination: content
        ))
    }

    
    func navDestination<Destination: View>(
        isPresented: Binding<Bool>,
        content: @escaping () -> Destination
    ) -> some View {
        modifier(NavViewPresentingModifier(
            isPresented: isPresented,
            destination: content
        ))
    }
    
    
    func navDestination<Value: Hashable, C: View>(
        value: Binding<Value?>,
        @ViewBuilder destination: @escaping (Value) -> C) -> some View
    {
        modifier(NavViewPresentingOptionalModifier(
            value: value,
            destination: destination
        ))
    }
    
}
