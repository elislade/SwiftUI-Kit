import SwiftUI

struct IndirectScrollRepresentation<Source: View> {
    
    let gesture: IndirectScrollGesture
    @ViewBuilder let content: () -> Source
    
}
