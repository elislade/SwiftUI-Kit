import SwiftUI

struct KeyPressPolyfill: ViewModifier {
    
    enum MaskType: Hashable {
        case charSet(CharacterSet)
        case equivalentSet(Set<KeyEquivalent>)
        
        func callAsFunction(_ press: KeyPress) -> Bool {
            switch self {
            case let .charSet(maskSet):
                let other = CharacterSet(charactersIn: press.characters)
                return maskSet.isSuperset(of: other)
            case let .equivalentSet(maskEquivalent):
                return maskEquivalent.contains(press.key)
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
