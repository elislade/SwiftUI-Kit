import SwiftUI
import SwiftUIKitCore

public struct NavBarDefaultMaterial : View {
    
    let showDivider: Bool
    
    public init(showDivider: Bool = true){
        self.showDivider = showDivider
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            BlurEffectView()
            if showDivider {
                Divider().ignoresSafeArea()
            }
        }
    }
    
}

#Preview("No Divider") {
    NavBarDefaultMaterial(showDivider: false)
}

#Preview("Divider") {
    NavBarDefaultMaterial(showDivider: true)
}
