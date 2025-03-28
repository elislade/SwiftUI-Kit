#if !os(watchOS)

import Foundation

struct KeyPressRepresentation {
    
    let mask: KeyPressViewModifier.MaskType?
    let phases: KeyPress.Phases
    let captured: (KeyPress) -> KeyPress.Result
    
    init(
        mask: KeyPressViewModifier.MaskType?,
        phases: KeyPress.Phases,
        captured: @escaping (KeyPress) -> KeyPress.Result
    ) {
        self.mask = mask
        self.phases = phases
        self.captured = captured
    }
    
}


#endif
