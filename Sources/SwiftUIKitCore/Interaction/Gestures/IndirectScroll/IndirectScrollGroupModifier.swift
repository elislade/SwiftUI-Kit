import SwiftUI


struct IndirectScrollGroupModifier {
    
    @State private var gestures: [WindowFrame<IndirectScrollGesture>] = []
    
}


extension IndirectScrollGroupModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        IndirectScrollRepresentation(
            gesture: { windowLocation in
                gestures.first(where: { $0.frame.contains(.init(windowLocation)) })?.value
            }
        ){
            content
        }
        .onPreferenceChange(IndirectGesturePreference.self){
            gestures = $0
        }
    }
    
}


@dynamicMemberLookup struct WindowFrame<Value> {
    
    let frame: CGRect
    let value: Value
    
    subscript <Subject>(dynamicMember keyPath: KeyPath<Value, Subject>) -> Subject {
        value[keyPath: keyPath]
    }
    
}


extension WindowFrame: Equatable where Value: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.frame == rhs.frame && lhs.value == rhs.value
    }
    
}


extension IndirectGesture {
    
    func window(frame: CGRect) -> WindowFrame<Self> {
        .init(frame: frame, value: self)
    }
    
}


struct IndirectGesturePreference: PreferenceKey {
    
    typealias Value = [WindowFrame<IndirectScrollGesture>]
    
    static var defaultValue: Value { [] }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
    
}
