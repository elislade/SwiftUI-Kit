import SwiftUI
import SwiftUIKitCore

public struct NavBarDefaultMaterial : View {
    
    let showDivider: Bool
    
    public init(showDivider: Bool = true){
        self.showDivider = showDivider
    }
    
    public var body: some View {
        if showDivider {
            ZStack(alignment: .bottom) {
                VisualEffectView()
                Divider().ignoresSafeArea()
            }
        } else {
            Rectangle().fill(.bar)
        }
    }
    
}

#Preview("No Divider") {
    NavBarDefaultMaterial(showDivider: false)
}

#Preview("Divider") {
    NavBarDefaultMaterial(showDivider: true)
}
