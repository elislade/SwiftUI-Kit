import SwiftUI


///  Equivalent to SwiftUI `NavigationLink`,  used to present views on ``NavView``.
public struct NavViewLink<Label: View, Value: Hashable> : View {
    
    @State private var id = UUID()
    @State private var isPresented = false
    
    private let value: Value
    private let label: () -> Label
    
    /// - Parameters:
    ///    - value: The value that will pe pushed onto the `NavView`.
    ///    - label: The view that visually indicates the link.
    public init(
        value: Value,
        @ViewBuilder label: @escaping () -> Label
    ){
        self.value = value
        self.label = label
    }
    
    public var body: some View {
        Button(action: { isPresented = true }, label: label)
            .buttonStyle(.plain)
            .preference(
                key: NavViewDestinationValueKey.self,
                value: isPresented ? [ .init(
                    id: id,
                    value: value,
                    dispose: {
                        isPresented = false
                    }
                ) ] : []
            )
    }
   
}
