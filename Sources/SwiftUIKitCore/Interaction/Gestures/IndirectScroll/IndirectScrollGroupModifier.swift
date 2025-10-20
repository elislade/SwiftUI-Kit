import SwiftUI

struct IndirectScrollGroupModifier {
    
    @State private var gestures: [WindowFrame<IndirectScrollGesture>] = []
    let isActive: Bool
    
}

extension IndirectScrollGroupModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        if isActive {
            IndirectScrollRepresentation(
                gesture: { windowLocation in
                    gestures.first(where: { $0.frame.contains(.init(windowLocation)) })?.value
                },
                content: {
                    content
                        //.releaseContainerSafeArea()
                        .ignoresSafeArea()
                }
            )
            .onPreferenceChange(IndirectGesturePreference.self){ gestures = $0 }
            .resetPreference(IndirectGesturePreference.self)
            //.captureContainerSafeArea()
        } else {
            content
        }
    }
    
}


@dynamicMemberLookup struct WindowFrame<Value> {
    
    let id: UUID
    let frame: CGRect
    let value: Value
    
    subscript <Subject>(dynamicMember keyPath: KeyPath<Value, Subject>) -> Subject {
        value[keyPath: keyPath]
    }
    
}


extension WindowFrame: Equatable where Value: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.frame == rhs.frame && lhs.value == rhs.value
    }
    
}


extension IndirectGesture {
    
    func window(id: UUID, frame: CGRect) -> WindowFrame<Self> {
        .init(id: id, frame: frame, value: self)
    }
    
}


struct IndirectGesturePreference: PreferenceKey {
    
    typealias Value = [WindowFrame<IndirectScrollGesture>]
    
    static var defaultValue: Value { [] }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
    
}
