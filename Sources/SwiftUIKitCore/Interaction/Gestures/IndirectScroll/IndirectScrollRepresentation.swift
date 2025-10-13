import SwiftUI

struct IndirectScrollRepresentation<Source: View> {
    
    let gesture: @MainActor (SIMD2<Double>) -> IndirectScrollGesture?
    let content: () -> Source
    
}
