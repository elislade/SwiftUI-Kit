import SwiftUI
import SwiftUIKitCore


struct MenuToggleStyle: ToggleStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.$isOn.wrappedValue.toggle() }){
            configuration.label
                .frame(maxWidth: .infinity, alignment: .leading)
                .equalInsetItem(.leading, .menuLeadingSpacerSize)
                .overlay(alignment: .leading) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .opacity(configuration.isOn ? 1 : 0)
                        .frame(width: 12)
                        .padding(.leading, 10)
                        .font(.body.weight(.semibold))
                }
        }
    }
    
}
