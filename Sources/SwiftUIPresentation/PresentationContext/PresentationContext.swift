import SwiftUI
import SwiftUIKitCore

extension View {

    nonisolated public func presentationContext() -> some View {
        basicPresentationContext()
            .focusPresentationContext()
            .anchorPresentationContext()
            .presentationMatchContext()
    }
    
}

