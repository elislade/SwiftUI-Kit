import SwiftUI
import SwiftUIKitCore


struct MenuToggleStyle: ToggleStyle {
    
    @State private var leadingSize: CGFloat = .menuLeadingSpacerSize
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.$isOn.wrappedValue.toggle() }){
            configuration.label
                .frame(maxWidth: .infinity, alignment: .leading)
                .equalInsetItem(.leading, leadingSize)
                .overlay(alignment: .leading) {
                    Image(systemName: "checkmark")
                        .opacity(configuration.isOn ? 1 : 0)
                        .padding(.horizontal, 10)
                        .font(.body.weight(.semibold))
                        .onGeometryChangePolyfill(of: { $0.size.width }){ leadingSize = $0 }
                }
        }
    }
    
}
