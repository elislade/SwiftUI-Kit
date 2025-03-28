#if !os(watchOS)

import Foundation

struct KeyPressRepresentation {
    
    let mask: KeyPressPolyfill.MaskType?
    let phases: KeyPress.Phases
    let captured: (KeyPress) -> KeyPress.Result
    
    init(
        mask: KeyPressPolyfill.MaskType?,
        phases: KeyPress.Phases,
        captured: @escaping (KeyPress) -> KeyPress.Result
    ) {
        self.mask = mask
        self.phases = phases
        self.captured = captured
    }
    
}


#endif
