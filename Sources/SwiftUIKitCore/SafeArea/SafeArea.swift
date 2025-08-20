import SwiftUI


extension View {
    
    public nonisolated func safeAreaInsets(_ inset: EdgeInsets, including edges: Edge.Set = .all) -> some View {
        safeAreaInset(edge: .top, spacing: 0){
            if edges.contains(.top) && inset.top > 0 {
                Color.clear.frame(height: inset.top)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0){
            if edges.contains(.bottom) && inset.bottom > 0 {
                Color.clear.frame(height: inset.bottom)
            }
        }
        .safeAreaInset(edge: .trailing, spacing: 0){
            if edges.contains(.trailing) && inset.trailing > 0 {
                Color.clear.frame(width: inset.trailing)
            }
        }
        .safeAreaInset(edge: .leading, spacing: 0){
            if edges.contains(.leading) && inset.leading > 0 {
                Color.clear.frame(width: inset.leading)
            }
        }
    }
    
    public nonisolated func safeAreaInsets(_ edges: Edge.Set = .all, _ amount: Double) -> some View {
        safeAreaInsets(.init(
            top: edges.contains(.top) ? amount : 0,
            leading: edges.contains(.leading) ? amount : 0,
            bottom: edges.contains(.bottom) ? amount : 0,
            trailing: edges.contains(.trailing) ? amount : 0
        ))
    }
    
}
