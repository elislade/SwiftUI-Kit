import SwiftUI


struct EqualInsetItemModifier: ViewModifier {
    
    @State private var id = UUID().uuidString
    @State private var insets: EdgeInsets = .init()
    
    let proposal: EdgeInsets?
    
    func body(content: Content) -> some View {
        content
            .padding(insets)
            .preference(key: EqualItemInsetPreferenceKey.self, value: [
                .init(id: id, proposal: proposal){ insets in
                    self.insets = insets
                }
            ])
    }
    
}


struct EqualItemInsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: [EqualItemInsetValue] { [] }
    
    static func reduce(value: inout [EqualItemInsetValue], nextValue: () -> [EqualItemInsetValue]) {
        value.append(contentsOf: nextValue())
    }
    
}


struct EqualItemInsetValue: Hashable {
    
    static func == (lhs: EqualItemInsetValue, rhs: EqualItemInsetValue) -> Bool {
        lhs.id == rhs.id && lhs.proposal == rhs.proposal
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: AnyHashable
    let proposal: EdgeInsets?
    let determinedInsets: (EdgeInsets) -> Void
}
