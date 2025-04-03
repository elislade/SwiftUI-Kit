#if !os(watchOS)

import SwiftUI

struct KeyPressViewModifier: ViewModifier {
    
    enum MaskType: Hashable, Sendable {
        case charSet(CharacterSet)
        case equivalentSet(Set<KeyEquivalent>)
        
        func callAsFunction(_ press: KeyPress) -> Bool {
            switch self {
            case let .charSet(maskSet):
                let other = CharacterSet(charactersIn: "\(press.key.character)")
                return maskSet.isSuperset(of: other) && press.modifiers.isEmpty
            case let .equivalentSet(maskEquivalent):
                return maskEquivalent.contains(press.key) && press.modifiers.isEmpty
            }
        }
    }
    
    var mask: MaskType? = nil
    let phases: KeyPress.Phases
    let action: (KeyPress) -> KeyPress.Result
    
    func body(content: Content) -> some View {
        content.background{
            KeyPressRepresentation(
                mask: mask,
                phases: phases,
                captured: action
            )
        }
    }
    
}


#endif
