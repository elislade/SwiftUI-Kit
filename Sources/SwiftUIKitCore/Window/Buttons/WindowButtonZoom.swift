import SwiftUI


public struct WindowButtonZoom: View {
    
    @Environment(\.performWindowAction) private var perform
    
    public init(){}
    
    public var body: some View {
        Button{ perform(.zoom) } label: {
            Label{
                Text("Maximize Window")
            } icon: {
                Image(systemName: "plus")
            }
        }
        .tint(.green)
    }
    
}


#Preview {
    HStack {
        WindowButtonZoom()
            .buttonStyle(.windowMain)
        
        WindowButtonZoom()
            .buttonStyle(.windowPanel)
    }
    .padding()
}
