import SwiftUI


struct EqualInsetContext: ViewModifier {
    
    let defaultInsets: EdgeInsets
    
    nonisolated init(defaultInsets: EdgeInsets) {
        self.defaultInsets = defaultInsets
    }
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(EqualItemInsetPreferenceKey.self){ value in
                let proposals = value.compactMap(\.proposal)
                
                let max = proposals.reduce(into: defaultInsets){ res, partial in
                    if partial.top > res.top { res.top = partial.top }
                    if partial.bottom > res.bottom { res.bottom = partial.bottom }
                    if partial.leading > res.leading { res.leading = partial.leading }
                    if partial.trailing > res.trailing { res.trailing = partial.trailing }
                }
                
                for item in value {
                    item.determinedInsets(max)
                }
            }
            .transformPreference(EqualItemInsetPreferenceKey.self){
                $0 = []
            }
    }
    
}
