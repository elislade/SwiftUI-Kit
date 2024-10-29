import SwiftUI

struct NavViewElement: Identifiable, Equatable {
    
    static func == (lhs: NavViewElement, rhs: NavViewElement) -> Bool {
        lhs.id == rhs.id && lhs.associatedValueID == rhs.associatedValueID
    }
    
    let id: UUID
    let view: AnyView
    let associatedValueID: UUID?
    let date: Date
    let dispose: () -> Void
    
    init(
        id: UUID,
        view: AnyView,
        associatedValueID: UUID? = nil,
        date: Date = Date(),
        dispose: @escaping () -> Void
    ) {
        self.id = id
        self.view = view
        self.associatedValueID = associatedValueID
        self.date = date
        self.dispose = dispose
    }
    
}


struct NavViewElementMetadata: Equatable {
    
    let associatedValueID: UUID?
    
}


struct NavViewElementPreferenceKey: PreferenceKey {
    
    static var defaultValue: [NavViewElement] = []
    
    static func reduce(value: inout [NavViewElement], nextValue: () -> [NavViewElement]) {
        value.append(contentsOf: nextValue())
    }
    
}
