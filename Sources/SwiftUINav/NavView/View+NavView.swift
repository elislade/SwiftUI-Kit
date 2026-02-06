import SwiftUI
import SwiftUIPresentation

extension View {
    
//    nonisolated public func navDestination<Value: Hashable>(
//        for valueType: Value.Type,
//        @ViewBuilder content: @MainActor @escaping (Value) -> some View
//    ) -> some View {
//        modifier(NavViewDestinationValueModifier(destination: content))
//    }
    
    nonisolated public func navDestination<Data: RangeReplaceableCollection>(
        data: Binding<Data>,
        @ViewBuilder content: @MainActor @escaping (Data.Element) -> some View
    ) -> some View where Data.Indices == Range<Int> {
        modifier(NavViewStackPresenter(
            data: data,
            destination: content
        ))
    }
    
    nonisolated public func navDestination(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @MainActor @escaping () -> some View
    ) -> some View {
        modifier(NavViewPresenter(
            value: isPresented,
            destination: { _ in content() }
        ))
    }
    
    nonisolated public func navDestination<Value: ValuePresentable>(
        value: Binding<Value>,
        @ViewBuilder destination: @MainActor @escaping (Value.Presented) -> some View) -> some View
    {
        modifier(NavViewPresenter(
            value: value,
            destination: destination
        ))
    }
    
}
