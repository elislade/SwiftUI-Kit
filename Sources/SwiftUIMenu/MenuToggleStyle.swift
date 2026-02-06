import SwiftUI
import SwiftUIControls
import SwiftUIKitCore


struct MenuToggleStyle: ToggleStyle {
    
    @Environment(\.menuStyle) private var style
    @State private var leadingSize: CGFloat = .menuLeadingSpacerSize
    
    var exclusivity: FormToggle.Exclusivity = .nonExclusive
    
    func makeBody(configuration: Configuration) -> some View {
        Button{ configuration.isOn.toggle() } label: {
            HStack {
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                FormToggle(isOn: configuration.$isOn, exclusivity: exclusivity)
                    .controlSize(.small)
            }
           // .equalInsetItem()
//            .overlay(alignment: .leading) {
//                Image(systemName: "checkmark")
//                    .opacity(configuration.isOn ? 1 : 0)
//                    .padding(.horizontal, 10)
//                    .font(.footnote[.bold])
//                    .onGeometryChangePolyfill(of: { $0.size.width }){ leadingSize = $0 }
//            }
        }
    }
    
}
