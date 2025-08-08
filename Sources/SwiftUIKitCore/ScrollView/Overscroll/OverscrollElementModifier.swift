import SwiftUI


struct OverscrollElementModifier: ViewModifier {
    
    let action: (Double) -> Void
    
    func body(content: Content) -> some View {
        content.anchorPreference(key: OverscrollElementPreference.self, value: .bounds){ a in
            [ .init(anchor: a, action: action) ]
        }
    }
    
}


struct OverscrollElement {
    
    let anchor: Anchor<CGRect>
    let action: (Double) -> Void
    
}


struct OverscrollElementPreference: PreferenceKey {

    static var defaultValue: [OverscrollElement] { [] }
    
    typealias Value = [OverscrollElement]
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
    
}
