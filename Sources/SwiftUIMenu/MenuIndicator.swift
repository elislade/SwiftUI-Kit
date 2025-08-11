import SwiftUI
import SwiftUIControls


public extension View {
    
    func menuIndicatorStyle() -> some View {
        #if os(macOS)
            frame(maxWidth: 150, alignment: .leading)
            .font(.body[.semibold])
                .padding(5)
                .padding(.leading, 5)
                .background{
                    ZStack(alignment: .trailing) {
                        RaisedControlMaterial(RoundedRectangle(cornerRadius: 8))
                        SunkenControlMaterial(
                            RoundedRectangle(cornerRadius: 8).inset(by: 3),
                            isTinted: true
                        )
                        .aspectRatio(0.9, contentMode: .fit)
                        .scaleEffect(-1)
                        .overlay {
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption[.bold])
                                .foregroundStyle(.white)
                        }
                    }
                }
        #else
        HStack {
            self
            Image(systemName: "chevron.up.chevron.down")
                .font(.body[.bold])
                .foregroundStyle(.tint)
        }
        .padding(1)
        .font(.body[.semibold])
        #endif
    }
    
}
