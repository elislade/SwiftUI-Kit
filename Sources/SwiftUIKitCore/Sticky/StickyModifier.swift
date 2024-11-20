import SwiftUI


struct StickyModifier: ViewModifier {

    @State private var id = UUID()
    @State private var offset: CGPoint = .zero
    
    let stickyInsets: OptionalEdgeInsets
    let behaviour: StickyGrouping?
    let category: StickyCategoryMask
    private let onChange: (StickingState) -> Void
    
    private var sticking: Bool { offset.x != 0 || offset.y != 0 }
    private var shouldStick: Bool { !stickyInsets.allNil }
    
    init(
        stickyInsets: OptionalEdgeInsets,
        category: StickyCategoryMask,
        behaviour: StickyGrouping?,
        onChange: @escaping (StickingState) -> Void = { _ in }
    ) {
        self.stickyInsets = stickyInsets
        self.behaviour = behaviour
        self.category = category
        self.onChange = onChange
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: shouldStick ? offset.x : 0, y: shouldStick ? offset.y : 0)
            .zIndex(shouldStick && sticking ? 1000 : 0)
            .anchorPreference(
                key: StickyPreferenceKey.self,
                value: .bounds
             ){ anchor in
                shouldStick ? [.init(
                    id: id,
                    insets: stickyInsets,
                    categoryMask: category,
                    grouping: behaviour,
                    anchor: anchor,
                    update: { offset, state in
                        //DispatchQueue.main.async {
                            if self.offset != offset {
                                self.offset = offset
                            }
                            onChange(state)
                        //}
                    }
                )] : []
             }
             .onChangePolyfill(of: shouldStick){ old, new in
                 if old && new == false {
                     onChange(.init())
                     offset = .zero
                 }
             }
    }
    
}
